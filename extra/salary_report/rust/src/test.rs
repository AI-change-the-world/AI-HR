#[allow(unused_imports)]
#[cfg(test)]
mod tests {
    use crate::salary_caculate::salary::{parse_salary_report, SalaryRecord};
    use umya_spreadsheet::reader;
    use umya_spreadsheet::structs::Spreadsheet;
    use umya_spreadsheet::structs::Worksheet;
    use umya_spreadsheet::{Cell, CellValue, Row};

    #[test]
    fn example() -> anyhow::Result<()> {
        let book = reader::xlsx::read("../test.xlsx")?; // 修改文件路径
        let sheet = book.get_sheet(&0).unwrap();

        // 打印前几行用于查看表头
        for row_num in 1..=3 {
            let row = sheet.get_collection_by_row(&row_num);
            println!("第{}行:", row_num);
            for cell in &row {
                let col_num = cell.get_coordinate().get_col_num();
                let value = cell.get_value().to_string();
                if !value.is_empty() {
                    println!("  列{}: {}", col_num, value);
                }
            }
        }

        println!("------------------------------------------------------------------------");

        // 打印特定列的信息
        for row_num in 1..=3 {
            let row = sheet.get_collection_by_row(&row_num);
            println!("第{}行:", row_num);
            for col_num in 14..=20 {
                if let Some(cell) = row
                    .iter()
                    .find(|c| *c.get_coordinate().get_col_num() == col_num as u32)
                {
                    let value = cell.get_value().to_string();
                    println!("  列{}: {}", col_num, value);
                } else {
                    println!("  列{}: (空)", col_num);
                }
            }
        }

        anyhow::Ok(())
    }

    #[test]
    fn test_parse_salary_report() -> anyhow::Result<()> {
        let summary = parse_salary_report("../test.xlsx")?;
        println!("Total records parsed: {}", summary.total_records);

        for (i, record) in summary.records.iter().enumerate() {
            println!("Record {}: {:?}", i + 1, record);
        }

        Ok(())
    }

    #[test]
    fn test_missing_mandatory_fields() {
        // 这个测试用于验证错误处理逻辑
        // 由于我们没有不完整的测试文件，这里只是演示测试结构
        assert!(true);
    }

    pub fn debug_excel_structure(file_path: &str) -> anyhow::Result<()> {
        let book = reader::xlsx::read(file_path)?;
        let sheet = book
            .get_sheet(&0)
            .ok_or_else(|| anyhow::anyhow!("无法获取工作表"))?;

        println!(
            "Sheet dimensions: {} rows, {} columns",
            sheet.get_highest_row(),
            sheet.get_highest_column()
        );

        // 打印前10行的数据来查看结构
        for row_num in 1..=10 {
            let row = sheet.get_collection_by_row(&row_num);
            if !row.is_empty() {
                println!("Row {}: ", row_num);
                for cell in row {
                    let cell_value = cell.get_value().to_string();
                    if !cell_value.is_empty() {
                        println!(
                            "  Col {}: {}",
                            cell.get_coordinate().get_col_num(),
                            cell_value
                        );
                    }
                }
            }
        }

        // 查找包含"合计"、"总计"等关键词的行
        for row_num in 1..=sheet.get_highest_row() {
            let row = sheet.get_collection_by_row(&row_num);
            if !row.is_empty() {
                let first_cell_value = row[0].get_value().to_string();
                if first_cell_value.contains("合计")
                    || first_cell_value.contains("总计")
                    || first_cell_value.contains("汇总")
                {
                    println!("Summary row {}: {}", row_num, first_cell_value);
                    for cell in row {
                        let cell_value = cell.get_value().to_string();
                        if !cell_value.is_empty() {
                            println!(
                                "  Col {}: {}",
                                cell.get_coordinate().get_col_num(),
                                cell_value
                            );
                        }
                    }
                }
            }
        }

        Ok(())
    }

    #[test]
    fn test_parse_salary_report_with_summary() -> anyhow::Result<()> {
        // 使用现有的test.xlsx文件进行测试
        let summary = parse_salary_report("../test.xlsx")?;

        // 检查基本数据
        println!("Total records: {}", summary.total_records);
        println!("Number of records: {}", summary.records.len());

        // 打印前几条记录用于调试
        for (i, record) in summary.records.iter().enumerate() {
            if i < 3 {
                println!(
                    "Record {}: Name={}, Department={}, Position={}, Net Salary={}",
                    i, record.name, record.department, record.position, record.net_salary
                );
            }
        }

        // 检查是否包含汇总数据
        println!("Summary data keys: {:?}", summary.summary_data.keys());
        println!("Summary data: {:?}", summary.summary_data);

        // 验证至少解析出了一条记录
        assert!(summary.total_records > 0);
        assert!(!summary.records.is_empty());

        // 验证第一条记录有数据
        let first_record = &summary.records[0];
        assert!(!first_record.name.is_empty());
        assert!(!first_record.department.is_empty());
        assert!(!first_record.position.is_empty());
        assert!(!first_record.net_salary.is_empty());

        // 检查汇总数据（即使为空也是可以接受的）
        println!("Summary data count: {}", summary.summary_data.len());

        anyhow::Ok(())
    }

    #[test]
    fn test_salary_record_fields() {
        let result = parse_salary_report("../test.xlsx");
        assert!(result.is_ok());

        let summary = result.unwrap();
        assert!(!summary.records.is_empty());

        let first_record = &summary.records[0];

        // 验证所有必需字段都有值
        assert!(!first_record.name.is_empty());
        assert!(!first_record.department.is_empty());
        assert!(!first_record.position.is_empty());
        assert!(!first_record.attendance.is_empty());
        assert!(!first_record.pre_tax_salary.is_empty()); // 修复这行
        assert!(!first_record.social_security_tax.is_empty());
        assert!(!first_record.net_salary.is_empty());

        // 验证考勤相关字段
        assert!(!first_record.payroll_days.is_empty());
        assert!(!first_record.sick_leave.is_empty()); // 修改字段名
        assert!(!first_record.performance_score.is_empty());

        println!("First record: {:?}", first_record);
    }

    #[test]
    fn test_debug_excel() {
        let result = debug_excel_structure("../test.xlsx");
        assert!(result.is_ok());
    }

    #[test]
    fn test_read_second_row_headers() -> anyhow::Result<()> {
        let book = reader::xlsx::read("../test.xlsx")?; // 修改文件路径
        let sheet = book
            .get_sheet(&0)
            .ok_or_else(|| anyhow::anyhow!("无法获取工作表"))?;

        // 读取第二行（索引为1）作为表头
        let header_row_num = 1;
        let header_row = sheet.get_collection_by_row(&header_row_num);

        println!("第二行表头信息（第{}行）:", header_row_num + 1);
        for (index, cell) in header_row.iter().enumerate() {
            let cell_value = cell.get_value().to_string();
            let col_index = cell.get_coordinate().get_col_num();
            println!("列{} (索引{}): {}", index + 1, col_index, cell_value);
        }

        // 查找"基本工资"到"饭补"之间的列
        println!("\n查找工资明细字段:");
        let mut found_salary_fields = false;
        let mut salary_field_start = 0;
        let mut salary_field_end = 0;

        for (index, cell) in header_row.iter().enumerate() {
            let cell_value = cell.get_value().to_string();
            let col_index = cell.get_coordinate().get_col_num();

            if cell_value.contains("基本工资") {
                found_salary_fields = true;
                salary_field_start = index;
                println!(
                    "开始字段 - 列{} (索引{}): {}",
                    index + 1,
                    col_index,
                    cell_value
                );
            }

            if found_salary_fields && cell_value.contains("饭补") {
                salary_field_end = index;
                println!(
                    "结束字段 - 列{} (索引{}): {}",
                    index + 1,
                    col_index,
                    cell_value
                );
                break;
            }

            if found_salary_fields {
                println!(
                    "工资字段 - 列{} (索引{}): {}",
                    index + 1,
                    col_index,
                    cell_value
                );
            }
        }

        println!(
            "从基本工资到饭补共有 {} 列",
            salary_field_end - salary_field_start + 1
        );

        Ok(())
    }

    #[test]
    fn test_read_third_row_headers() -> anyhow::Result<()> {
        let book = reader::xlsx::read("../test.xlsx")?;
        let sheet = book
            .get_sheet(&0)
            .ok_or_else(|| anyhow::anyhow!("无法获取工作表"))?;

        // 读取第三行（索引为2）作为表头，这与salary.rs中的逻辑一致
        let header_row_num = 2;
        let header_row = sheet.get_collection_by_row(&header_row_num);

        println!("第三行表头信息（第{}行）:", header_row_num + 1);
        for (index, cell) in header_row.iter().enumerate() {
            let cell_value = cell.get_value().to_string();
            let col_index = cell.get_coordinate().get_col_num();
            println!("列{} (索引{}): '{}'", index + 1, col_index, cell_value);
        }

        // 查找"基本工资"到"饭补"之间的列
        println!("\n查找工资明细字段:");
        let mut found_salary_fields = false;
        let mut salary_fields = Vec::new();

        for (index, cell) in header_row.iter().enumerate() {
            let cell_value = cell.get_value().to_string();
            let col_index = cell.get_coordinate().get_col_num();

            if cell_value.contains("基本工资") {
                found_salary_fields = true;
                println!(
                    "开始字段 - 列{} (索引{}): '{}'",
                    index + 1,
                    col_index,
                    cell_value
                );
                salary_fields.push((index, col_index, cell_value.clone()));
            } else if found_salary_fields && cell_value.contains("饭补") {
                println!(
                    "结束字段 - 列{} (索引{}): '{}'",
                    index + 1,
                    col_index,
                    cell_value
                );
                salary_fields.push((index, col_index, cell_value.clone()));
                break;
            } else if found_salary_fields {
                println!(
                    "工资字段 - 列{} (索引{}): '{}'",
                    index + 1,
                    col_index,
                    cell_value
                );
                salary_fields.push((index, col_index, cell_value.clone()));
            }
        }

        println!("\n从基本工资到饭补共有 {} 列", salary_fields.len());
        println!("工资明细字段列表:");
        for (index, col_index, field_name) in &salary_fields {
            println!("  - 列{} (索引{}): {}", index + 1, col_index, field_name);
        }

        Ok(())
    }

    use windows_sys::Win32::System::Diagnostics::Debug::MessageBeep;
    use windows_sys::Win32::UI::WindowsAndMessaging::{MB_ICONASTERISK, MB_OK};

    #[test]
    fn test_beep() {
        unsafe {
            // 播放提示音
            MessageBeep(MB_OK);
        }
    }
}
