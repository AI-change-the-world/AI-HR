use crate::salary_caculate::salary::{parse_salary_report, SalarySummary};

pub fn get_caculate_result(p: String) -> (String, Option<SalarySummary>) {
    let res = parse_salary_report(&p);
    match res {
        Ok(_res) => {
            return ("".to_string(), Some(_res));
        }
        Err(_e) => {
            return (format!("{}", _e), None);
        }
    }
}
