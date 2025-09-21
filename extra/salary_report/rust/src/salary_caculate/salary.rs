use anyhow::Result;
use std::collections::HashMap;
use umya_spreadsheet::reader;

/// 工资记录
#[derive(Debug, Clone)]
pub struct SalaryRecord {
    // 必须要有的字段
    pub name: String,                // 姓名
    pub department: String,          // 一级部门
    pub position: String,            // 职位
    pub attendance: String,          // 实际出勤折算天数
    pub pre_tax_salary: String,      // 税前工资
    pub social_security_tax: String, // 社保公积金个人部分合计
    pub net_salary: String,          // 税后应实发
    // 可选字段
    pub serial_number: String,        // 序号
    pub hire_date: String,            // 入职日期
    pub termination_date: String,     // 离职日期
    pub gender: String,               // 性别
    pub id_number: String,            // 身份证号
    pub regularization_date: String,  // 转正日期
    pub contract_type: String,        // 合同类型
    pub financial_aggregation: String, // 财务归集
    pub secondary_department: String, // 二级部门
    pub job_level: String,            // 职级
    pub payroll_days: String,         // 计薪日天数
    pub sick_leave: String,           // 病假（天）
    pub personal_leave: String,       // 事假（小时）
    pub absence: String,              // 缺勤（次）
    pub truancy: String,              // 旷工（天）
    pub performance_score: String,    // 绩效得分
    pub basic_salary: String,         // 基本工资
    pub position_salary: String,      // 岗位工资
    pub performance_salary: String,   // 绩效工资
    pub allowance_salary: String,     // 补贴工资
    pub comprehensive_salary: String, // 综合薪资标准
    pub current_month_basic: String,  // 当月基本工资
    pub current_month_position: String, // 当月岗位工资
    pub current_month_performance: String, // 当月绩效工资
    pub current_month_allowance: String, // 当月补贴工资
    pub current_month_sick_deduction: String, // 当月病假扣减
    pub current_month_personal_leave_deduction: String, // 当月事假扣减
    pub current_month_absence_deduction: String, // 当月缺勤扣减
    pub current_month_truancy_deduction: String, // 当月旷工扣减
    pub meal_allowance: String,       // 饭补
    pub computer_allowance: String,   // 电脑补贴等
    pub other_adjustments: String,    // 其他增减
    pub monthly_payroll_salary: String, // 当月计薪工资
    pub social_security_base: String, // 社保基数
    pub provident_fund_base: String,  // 公积金基数
    pub personal_pension: String,     // 个人养老
    pub personal_medical: String,     // 个人医疗
    pub personal_unemployment: String, // 个人失业
    pub personal_provident_fund: String, // 个人公积金
    pub monthly_personal_income_tax: String, // 当月个人所得税
    pub severance_pay: String,        // 离职补偿金
    pub post_tax_adjustments: String, // 税后增减
    pub bank: String,                 // 所属银行
    pub bank_account: String,         // 银行卡号
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
    
    // 必需字段，如果这些字段不存在则返回错误
    let mandatory_fields = [
        ("姓名", "name"),
        ("一级部门", "department"),
        ("职位", "position"),
        ("实际出勤折算天数", "attendance"),
        ("税前工资", "pre_tax_salary"),  // 修复这行，保持一致性
        ("社保公积金个人部分合计", "social_security_tax"),
        ("税后应实发", "net_salary"),
    ];

    // 所有可能的字段映射
    let all_fields = [
        ("序号", "serial_number"),
        ("入职日期", "hire_date"),
        ("离职日期", "termination_date"),
        ("性别", "gender"),
        ("身份证号", "id_number"),
        ("转正日期", "regularization_date"),
        ("合同类型", "contract_type"),
        ("财务归集", "financial_aggregation"),
        ("一级部门", "department"),
        ("二级部门", "secondary_department"),
        ("职级", "job_level"),
        ("职位", "position"),
        ("计薪日天数", "payroll_days"),
        ("实际出勤折算天数", "attendance"),
        // 考勤相关字段使用包含匹配
        ("病假", "sick_leave"),      // 包含"病假"即可匹配
        ("事假", "personal_leave"),   // 包含"事假"即可匹配
        ("缺勤", "absence"),         // 包含"缺勤"即可匹配
        ("旷工", "truancy"),         // 包含"旷工"即可匹配
        ("绩效得分", "performance_score"),
        ("基本工资", "basic_salary"),
        ("岗位工资", "position_salary"),
        ("绩效工资", "performance_salary"),
        ("补贴工资", "allowance_salary"),
        ("综合薪资标准", "comprehensive_salary"),
        ("当月基本工资", "current_month_basic"),
        ("当月岗位工资", "current_month_position"),
        ("当月绩效工资", "current_month_performance"),
        ("当月补贴工资", "current_month_allowance"),
        ("当月病假扣减", "current_month_sick_deduction"),
        ("当月事假扣减", "current_month_personal_leave_deduction"),
        ("当月缺勤扣减", "current_month_absence_deduction"),
        ("当月旷工扣减", "current_month_truancy_deduction"),
        ("饭补", "meal_allowance"),
        ("电脑补贴等", "computer_allowance"),
        ("其他增减", "other_adjustments"),
        ("当月计薪工资", "monthly_payroll_salary"),
        ("社保基数", "social_security_base"),
        ("公积金基数", "provident_fund_base"),
        ("个人养老", "personal_pension"),
        ("个人医疗", "personal_medical"),
        ("个人失业", "personal_unemployment"),
        ("个人公积金", "personal_provident_fund"),
        ("社保公积金个人部分合计", "social_security_tax"),
        ("税前工资", "pre_tax_salary"),  // 添加这行
        ("当月个人所得税", "monthly_personal_income_tax"),
        ("离职补偿金", "severance_pay"),
        ("税后增减", "post_tax_adjustments"),
        ("税后应实发", "net_salary"),
        ("所属银行", "bank"),
        ("银行卡号", "bank_account"),
        ("姓名", "name"),  // 添加这行
    ];

    // 查找表头中的字段索引
    for cell in header_row {
        let cell_value = cell.get_value().to_string();
        // 清理单元格值，去除换行符和首尾空格
        let cleaned_cell_value = cell_value.replace("\n", "").replace("\r", "").trim().to_string();
        for (chinese_name, field_name) in &all_fields {
            // 对于考勤相关字段使用包含匹配，其他字段使用完全匹配
            let is_match = if matches!(*field_name, "sick_leave" | "personal_leave" | "absence" | "truancy") {
                cleaned_cell_value.contains(chinese_name)
            } else {
                cleaned_cell_value == *chinese_name
            };
            
            if is_match {
                field_indices.insert(field_name.to_string(), cell.get_coordinate().get_col_num());
                break;
            }
        }
    }

    // 检查必需字段是否存在
    for (chinese_name, field_name) in &mandatory_fields {
        if !field_indices.contains_key(*field_name) {
            println!("模板不符合要求：缺少必需字段 '{}',完整列表如下： {:?}", chinese_name, field_indices);
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

        // 获取姓名、部门和税后应实发字段的值
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

        let department_cell_value = if let Some(&col_index) = field_indices.get("department") {
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

        let net_salary_cell_value = if let Some(&col_index) = field_indices.get("net_salary") {
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

        // 判断是否为汇总行：税后应实发有数据但没有人员信息和部门信息
        if !net_salary_cell_value.is_empty()
            && name_cell_value.is_empty()
            && department_cell_value.is_empty()
        {
            // 提取汇总行数据
            for cell in row {
                let col_index = cell.get_coordinate().get_col_num();
                let cell_value = cell.get_value().to_string();

                // 只有当单元格有值时才保存
                if !cell_value.is_empty() {
                    // 尝试找到对应的字段名
                    let field_name = field_indices
                        .iter()
                        .find(|(_, &index)| index == col_index)
                        .map(|(name, _)| name.clone())
                        .unwrap_or_else(|| format!("summary_col_{}", u32_to_excel_column(*col_index)));

                    // 如果找到了字段名，使用中文字段名
                    let display_name = match field_name.as_str() {
                        "serial_number" => "序号".to_string(),
                        "hire_date" => "入职日期".to_string(),
                        "termination_date" => "离职日期".to_string(),
                        "gender" => "性别".to_string(),
                        "id_number" => "身份证号".to_string(),
                        "regularization_date" => "转正日期".to_string(),
                        "contract_type" => "合同类型".to_string(),
                        "financial_aggregation" => "财务归集".to_string(),
                        "department" => "一级部门".to_string(),
                        "secondary_department" => "二级部门".to_string(),
                        "job_level" => "职级".to_string(),
                        "position" => "职位".to_string(),
                        "payroll_days" => "计薪日天数".to_string(),
                        "attendance" => "实际出勤折算天数".to_string(),
                        "sick_leave" => "病假（天）".to_string(),
                        "personal_leave" => "事假（小时）".to_string(),
                        "absence" => "缺勤（次）".to_string(),
                        "truancy" => "旷工（天）".to_string(),
                        "performance_score" => "绩效得分".to_string(),
                        "basic_salary" => "基本工资".to_string(),
                        "position_salary" => "岗位工资".to_string(),
                        "performance_salary" => "绩效工资".to_string(),
                        "allowance_salary" => "补贴工资".to_string(),
                        "comprehensive_salary" => "综合薪资标准".to_string(),
                        "current_month_basic" => "当月基本工资".to_string(),
                        "current_month_position" => "当月岗位工资".to_string(),
                        "current_month_performance" => "当月绩效工资".to_string(),
                        "current_month_allowance" => "当月补贴工资".to_string(),
                        "current_month_sick_deduction" => "当月病假扣减".to_string(),
                        "current_month_personal_leave_deduction" => "当月事假扣减".to_string(),
                        "current_month_absence_deduction" => "当月缺勤扣减".to_string(),
                        "current_month_truancy_deduction" => "当月旷工扣减".to_string(),
                        "meal_allowance" => "饭补".to_string(),
                        "computer_allowance" => "电脑补贴等".to_string(),
                        "other_adjustments" => "其他增减".to_string(),
                        "monthly_payroll_salary" => "当月计薪工资".to_string(),
                        "social_security_base" => "社保基数".to_string(),
                        "provident_fund_base" => "公积金基数".to_string(),
                        "personal_pension" => "个人养老".to_string(),
                        "personal_medical" => "个人医疗".to_string(),
                        "personal_unemployment" => "个人失业".to_string(),
                        "personal_provident_fund" => "个人公积金".to_string(),
                        "pre_tax_salary" => "税前工资".to_string(),
                        "monthly_personal_income_tax" => "当月个人所得税".to_string(),
                        "severance_pay" => "离职补偿金".to_string(),
                        "post_tax_adjustments" => "税后增减".to_string(),
                        "net_salary" => "税后应实发".to_string(),
                        "bank" => "所属银行".to_string(),
                        "bank_account" => "银行卡号".to_string(),
                        _ => field_name,
                    };

                    summary_data.insert(display_name, cell_value);
                }
            }

            row_num += 1;
            continue;
        }

        // 如果姓名为空且税后应实发也为空，说明是空行，停止解析
        if name_cell_value.is_empty() && net_salary_cell_value.is_empty() {
            break;
        }

        // 提取需要的字段数据
        let mut record = SalaryRecord {
            name: String::new(),
            department: String::new(),
            position: String::new(),
            attendance: String::new(),
            pre_tax_salary: String::new(),  // 修复这行
            social_security_tax: String::new(),
            net_salary: String::new(),
            // 可选字段
            serial_number: String::new(),
            hire_date: String::new(),
            termination_date: String::new(),
            gender: String::new(),
            id_number: String::new(),
            regularization_date: String::new(),
            contract_type: String::new(),
            financial_aggregation: String::new(),
            secondary_department: String::new(),
            job_level: String::new(),
            payroll_days: String::new(),
            sick_leave: String::new(),
            personal_leave: String::new(),
            absence: String::new(),
            truancy: String::new(),
            performance_score: String::new(),
            basic_salary: String::new(),
            position_salary: String::new(),
            performance_salary: String::new(),
            allowance_salary: String::new(),
            comprehensive_salary: String::new(),
            current_month_basic: String::new(),
            current_month_position: String::new(),
            current_month_performance: String::new(),
            current_month_allowance: String::new(),
            current_month_sick_deduction: String::new(),
            current_month_personal_leave_deduction: String::new(),
            current_month_absence_deduction: String::new(),
            current_month_truancy_deduction: String::new(),
            meal_allowance: String::new(),
            computer_allowance: String::new(),
            other_adjustments: String::new(),
            monthly_payroll_salary: String::new(),
            social_security_base: String::new(),
            provident_fund_base: String::new(),
            personal_pension: String::new(),
            personal_medical: String::new(),
            personal_unemployment: String::new(),
            personal_provident_fund: String::new(),
            monthly_personal_income_tax: String::new(),
            severance_pay: String::new(),
            post_tax_adjustments: String::new(),
            bank: String::new(),
            bank_account: String::new(),
        };

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
                    "pre_tax_salary" => record.pre_tax_salary = value,  // 修复这行
                    "social_security_tax" => record.social_security_tax = value,
                    "net_salary" => record.net_salary = value,
                    // 可选字段
                    "serial_number" => record.serial_number = value,
                    "hire_date" => record.hire_date = value,
                    "termination_date" => record.termination_date = value,
                    "gender" => record.gender = value,
                    "id_number" => record.id_number = value,
                    "regularization_date" => record.regularization_date = value,
                    "contract_type" => record.contract_type = value,
                    "financial_aggregation" => record.financial_aggregation = value,
                    "secondary_department" => record.secondary_department = value,
                    "job_level" => record.job_level = value,
                    "payroll_days" => record.payroll_days = value,
                    "sick_leave" => record.sick_leave = value,
                    "personal_leave" => record.personal_leave = value,
                    "absence" => record.absence = value,
                    "truancy" => record.truancy = value,
                    "performance_score" => record.performance_score = value,
                    "basic_salary" => record.basic_salary = value,
                    "position_salary" => record.position_salary = value,
                    "performance_salary" => record.performance_salary = value,
                    "allowance_salary" => record.allowance_salary = value,
                    "comprehensive_salary" => record.comprehensive_salary = value,
                    "current_month_basic" => record.current_month_basic = value,
                    "current_month_position" => record.current_month_position = value,
                    "current_month_performance" => record.current_month_performance = value,
                    "current_month_allowance" => record.current_month_allowance = value,
                    "current_month_sick_deduction" => record.current_month_sick_deduction = value,
                    "current_month_personal_leave_deduction" => record.current_month_personal_leave_deduction = value,
                    "current_month_absence_deduction" => record.current_month_absence_deduction = value,
                    "current_month_truancy_deduction" => record.current_month_truancy_deduction = value,
                    "meal_allowance" => record.meal_allowance = value,
                    "computer_allowance" => record.computer_allowance = value,
                    "other_adjustments" => record.other_adjustments = value,
                    "monthly_payroll_salary" => record.monthly_payroll_salary = value,
                    "social_security_base" => record.social_security_base = value,
                    "provident_fund_base" => record.provident_fund_base = value,
                    "personal_pension" => record.personal_pension = value,
                    "personal_medical" => record.personal_medical = value,
                    "personal_unemployment" => record.personal_unemployment = value,
                    "personal_provident_fund" => record.personal_provident_fund = value,
                    "monthly_personal_income_tax" => record.monthly_personal_income_tax = value,
                    "severance_pay" => record.severance_pay = value,
                    "post_tax_adjustments" => record.post_tax_adjustments = value,
                    "bank" => record.bank = value,
                    "bank_account" => record.bank_account = value,
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


fn u32_to_excel_column(mut n: u32) -> String {
    let mut s = String::new();
    while n > 0 {
        n -= 1; // Excel 列号是 1-based
        let c = ((n % 26) as u8 + b'A') as char;
        s.insert(0, c);
        n /= 26;
    }
    s
}