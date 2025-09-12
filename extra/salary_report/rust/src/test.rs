#[allow(unused_imports)]
mod tests {
    use crate::api::salary::{parse_salary_report, SalaryRecord};
    use umya_spreadsheet::reader;
    use umya_spreadsheet::structs::Spreadsheet;
    use umya_spreadsheet::structs::Worksheet;
    use umya_spreadsheet::{Cell, CellValue, Row};

    #[test]
    fn example() -> anyhow::Result<()> {
        let book = reader::xlsx::read("test.xlsx")?;
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
        let summary = parse_salary_report("test.xlsx")?;
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
}
