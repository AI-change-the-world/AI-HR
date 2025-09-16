use crate::salary_caculate::salary::{parse_salary_report, SalarySummary};

/// 获取工资计算结果
/// 
/// # 参数
/// * `file_path` - Excel文件路径
/// 
/// # 返回值
/// 返回(错误信息, SalarySummary)元组，如果成功则错误信息为空
pub fn get_caculate_result(file_path: String) -> (String, Option<SalarySummary>) {
    let res = parse_salary_report(&file_path);
    match res {
        Ok(summary) => {
            return ("".to_string(), Some(summary));
        }
        Err(e) => {
            return (format!("{}", e), None);
        }
    }
}