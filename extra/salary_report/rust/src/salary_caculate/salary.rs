use anyhow::Result;
use std::collections::HashMap;
use umya_spreadsheet::reader;

/// 工资记录
#[derive(Debug, Clone)]
pub struct SalaryRecord {
    pub name: String,                // 姓名
    pub department: String,          // 部门
    pub position: String,            // 岗位
    pub attendance: String,          // 出勤
    pub salary_components: String,   // 工资构成
    pub social_security_tax: String, // 社保个税
    pub net_salary: String,          // 实发工资
    // 考勤相关字段
    pub payroll_days: String,           // 计薪日天数
    pub actual_attendance_days: String, // 实际出勤折算天数
    pub sick_leave: String,             // 病假/天
    pub personal_leave: String,         // 事假/hr
    pub absence: String,                // 缺勤/次
    pub truancy: String,                // 旷工/天
    pub performance_score: String,      // 绩效得分
}

/// 工资汇总信息
#[derive(Debug)]
pub struct SalarySummary {
    pub total_records: usize,
    pub records: Vec<SalaryRecord>,
    /// 汇总行数据，键为字段名或列索引，值为单元格内容
    pub summary_data: HashMap<String, String>,
}

/// 解析工资报表Excel文件
///
/// # 参数
/// * `file_path` - Excel文件路径
///
/// # 返回值
/// 返回解析结果，包含所有工资记录和可能的汇总信息
pub fn parse_salary_report(file_path: &str) -> Result<SalarySummary> {
    let book = reader::xlsx::read(file_path)?;
    let sheet = book
        .get_sheet(&0)
        .ok_or_else(|| anyhow::anyhow!("无法获取工作表"))?;

    // 查找表头行（第三行，索引为2）
    let header_row_num = 2; // 第三行是字段名
    let header_row = sheet.get_collection_by_row(&header_row_num);

    // 查找需要的字段索引
    let mut field_indices = HashMap::new();
    let required_fields = [
        ("姓名", "name"),
        ("一级部门", "department"),         // 使用"一级部门"而不是"部门"
        ("职位", "position"),               // 使用"职位"而不是"岗位"
        ("实际出勤折算天数", "attendance"), // 使用"实际出勤折算天数"作为出勤字段
        ("税前工资", "salary_components"),  // 使用"税前工资"作为工资构成
        ("社保公积金个人部分合计", "social_security_tax"), // 使用"社保公积金个人部分合计"作为社保个税
        ("税后应实发", "net_salary"),                      // 使用"税后应实发"作为实发工资
        // 考勤相关字段（除了实际出勤折算天数，因为它已经作为attendance字段使用了）
        ("计薪日天数", "payroll_days"),
        ("病假\n/天", "sick_leave"),
        ("事假\n/hr", "personal_leave"),
        ("缺勤\n/次", "absence"),
        ("旷工\n/天", "truancy"),
        ("绩效得分", "performance_score"),
    ];

    // 必需字段，如果这些字段不存在则返回错误
    let mandatory_fields = [
        ("姓名", "name"),
        ("一级部门", "department"),
        ("职位", "position"),
        ("实际出勤折算天数", "attendance"),
        ("税前工资", "salary_components"),
        ("社保公积金个人部分合计", "social_security_tax"),
        ("税后应实发", "net_salary"),
    ];

    for cell in header_row {
        let cell_value = cell.get_value().to_string();
        for (chinese_name, field_name) in &required_fields {
            if cell_value.contains(chinese_name) {
                field_indices.insert(field_name.to_string(), cell.get_coordinate().get_col_num());
                break;
            }
        }
    }

    // 检查必需字段是否存在
    for (chinese_name, field_name) in &mandatory_fields {
        if !field_indices.contains_key(*field_name) {
            anyhow::bail!("模板不符合要求：缺少必需字段 '{}'", chinese_name);
        }
    }

    // 解析数据行
    let mut records = Vec::new();
    let mut summary_data = HashMap::new(); // 初始化汇总数据
    let mut row_num = header_row_num + 1;

    // 遍历所有行直到遇到非数据行或文件结束
    loop {
        let row = sheet.get_collection_by_row(&row_num);

        // 检查是否是空行或者已经没有更多行了
        if row.is_empty() {
            break;
        }

        // 检查是否是非数据行（如制表人、审核人等）
        let first_cell_value = if !row.is_empty() {
            row[0].get_value().to_string()
        } else {
            String::new()
        };

        // 如果遇到明显不是数据行的行，则提取为汇总信息
        if first_cell_value.contains("制表")
            || first_cell_value.contains("审核")
            || first_cell_value.contains("核准")
            || first_cell_value.contains("更新")
            || first_cell_value.contains("新入职")
            || first_cell_value.contains("离职/待离职")
            || first_cell_value.contains("三期员工")
        {
            // 提取这些行作为汇总信息
            for cell in row {
                let col_index = cell.get_coordinate().get_col_num();
                let cell_value = cell.get_value().to_string();

                // 只有当单元格有值时才保存
                if !cell_value.is_empty() {
                    let field_name = format!("summary_{}", col_index);
                    summary_data.insert(field_name, cell_value);
                }
            }

            row_num += 1;
            continue; // 继续检查下一行，看是否还有更多汇总信息
        }

        // 如果姓名为空但行不为空，可能是汇总行
        let name_cell_value = if let Some(&col_index) = field_indices.get("name") {
            if let Some(cell) = row
                .iter()
                .find(|c| c.get_coordinate().get_col_num() == col_index)
            {
                cell.get_value().to_string()
            } else {
                String::new()
            }
        } else {
            String::new()
        };

        // 如果姓名为空但行不为空，可能是汇总行
        if name_cell_value.is_empty() && !first_cell_value.is_empty() {
            // 提取汇总行数据
            for cell in row {
                let col_index = cell.get_coordinate().get_col_num();
                let cell_value = cell.get_value().to_string();

                // 只有当单元格有值时才保存
                if !cell_value.is_empty() {
                    let field_name = format!("summary_col_{}", col_index);
                    summary_data.insert(field_name, cell_value);
                }
            }

            row_num += 1;
            continue;
        }

        // 如果姓名为空且第一列也为空，说明是空行，停止解析
        if name_cell_value.is_empty() && first_cell_value.is_empty() {
            break;
        }

        // 提取需要的字段数据
        let mut record = SalaryRecord {
            name: String::new(),
            department: String::new(),
            position: String::new(),
            attendance: String::new(),
            salary_components: String::new(),
            social_security_tax: String::new(),
            net_salary: String::new(),
            // 考勤相关字段
            payroll_days: String::new(),
            actual_attendance_days: String::new(), // 这个字段需要特殊处理
            sick_leave: String::new(),
            personal_leave: String::new(),
            absence: String::new(),
            truancy: String::new(),
            performance_score: String::new(),
        };

        // 特殊处理actual_attendance_days字段（与attendance字段相同）
        if let Some(&col_index) = field_indices.get("attendance") {
            if let Some(cell) = row
                .iter()
                .find(|c| c.get_coordinate().get_col_num() == col_index)
            {
                record.actual_attendance_days = cell.get_value().to_string();
            }
        }

        for (field_name, &col_index) in &field_indices {
            if let Some(cell) = row
                .iter()
                .find(|c| c.get_coordinate().get_col_num() == col_index)
            {
                let value = cell.get_value().to_string();
                match field_name.as_str() {
                    "name" => record.name = value,
                    "department" => record.department = value,
                    "position" => record.position = value,
                    "attendance" => record.attendance = value,
                    "salary_components" => record.salary_components = value,
                    "social_security_tax" => record.social_security_tax = value,
                    "net_salary" => record.net_salary = value,
                    // 考勤相关字段
                    "payroll_days" => record.payroll_days = value,
                    "sick_leave" => record.sick_leave = value,
                    "personal_leave" => record.personal_leave = value,
                    "absence" => record.absence = value,
                    "truancy" => record.truancy = value,
                    "performance_score" => record.performance_score = value,
                    _ => {}
                }
            }
        }

        // 只有当姓名不为空时才添加记录
        if !record.name.is_empty() {
            records.push(record);
        }

        row_num += 1;
    }

    Ok(SalarySummary {
        total_records: records.len(),
        records,
        summary_data,
    })
}
