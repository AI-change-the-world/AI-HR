# 多月工资分析报告可用数据类型说明

本文档整理了多月工资分析页面中所有可用于生成报告的数据类型和结构。

## 1. 整体统计数据

### 1.1 基础统计信息
- `totalEmployees`: 总人次（不去重）
- `totalUniqueEmployees`: 总人数（去重）
- `totalSalary`: 工资总额
- `averageSalary`: 平均工资
- `highestSalary`: 最高工资
- `lowestSalary`: 最低工资

### 1.2 薪资区间统计
- `salaryRanges`: 薪资区间分布数据
  - `range`: 区间名称
  - `employeeCount`: 员工数量
  - `totalSalary`: 工资总额
  - `averageSalary`: 平均工资
  - `year`: 年份
  - `month`: 月份

## 2. 部门统计数据

### 2.1 部门工资统计
- `departmentStats`: 部门统计数据列表
  - `department`: 部门名称
  - `totalNetSalary`: 部门工资总额
  - `averageNetSalary`: 部门平均工资
  - `employeeCount`: 部门员工数量
  - `year`: 年份
  - `month`: 月份
  - `maxSalary`: 部门最高工资
  - `minSalary`: 部门最低工资

### 2.2 每月部门统计
- `departmentDetailsPerMonth`: 每月部门详情数据
  - `month`: 月份标签
  - `departments`: 部门数据映射（部门名称 -> 平均工资）

## 3. 考勤统计数据

### 3.1 考勤统计
- `attendanceStats`: 考勤统计数据列表
  - `name`: 员工姓名
  - `department`: 部门
  - `sickLeaveDays`: 病假天数
  - `leaveDays`: 事假天数
  - `absenceCount`: 旷工次数
  - `truancyDays`: 旷工天数
  - `year`: 年份
  - `month`: 月份

## 4. 时间序列数据

### 4.1 每月员工数量变化
- `employeeCountPerMonth`: 每月员工数量数据
  - `month`: 月份标签
  - `year`: 年份
  - `monthNum`: 月份数字
  - `employeeCount`: 员工数量

### 4.2 每月平均工资变化
- `averageSalaryPerMonth`: 每月平均工资数据
  - `month`: 月份标签
  - `year`: 年份
  - `monthNum`: 月份数字
  - `averageSalary`: 平均工资

### 4.3 每月工资总额变化
- `totalSalaryPerMonth`: 每月工资总额数据
  - `month`: 月份标签
  - `year`: 年份
  - `monthNum`: 月份数字
  - `totalSalary`: 工资总额

## 5. 部门和岗位趋势分析数据

### 5.1 部门环比变化数据
- `departmentMonthOverMonthData`: 部门环比变化数据
  - `department`: 部门名称
  - `employee_count_change`: 员工数量变化
  - `employee_count_change_percent`: 员工数量变化率
  - `total_salary_change`: 工资总额变化
  - `total_salary_change_percent`: 工资总额变化率
  - `average_salary_change`: 平均工资变化
  - `average_salary_change_percent`: 平均工资变化率

### 5.2 部门同比变化数据
- `departmentYearOverYearData`: 部门同比变化数据
  - `department`: 部门名称
  - `employee_count_change`: 员工数量变化
  - `employee_count_change_percent`: 员工数量变化率
  - `total_salary_change`: 工资总额变化
  - `total_salary_change_percent`: 工资总额变化率
  - `average_salary_change`: 平均工资变化
  - `average_salary_change_percent`: 平均工资变化率

### 5.3 岗位环比变化数据
- `positionMonthOverMonthData`: 岗位环比变化数据
  - `position`: 岗位名称
  - `employee_count_change`: 员工数量变化
  - `employee_count_change_percent`: 员工数量变化率
  - `total_salary_change`: 工资总额变化
  - `total_salary_change_percent`: 工资总额变化率
  - `average_salary_change`: 平均工资变化
  - `average_salary_change_percent`: 平均工资变化率

### 5.4 岗位同比变化数据
- `positionYearOverYearData`: 岗位同比变化数据
  - `position`: 岗位名称
  - `employee_count_change`: 员工数量变化
  - `employee_count_change_percent`: 员工数量变化率
  - `total_salary_change`: 工资总额变化
  - `total_salary_change_percent`: 工资总额变化率
  - `average_salary_change`: 平均工资变化
  - `average_salary_change_percent`: 平均工资变化率

## 6. 报告专用字段

### 6.1 多月报告特有字段
- `monthCount`: 报告涵盖的月份数量
- `totalSalaryGrowthRate`: 总工资增长率
- `averageSalaryGrowthRate`: 平均工资增长率
- `trendAnalysisSummary`: 趋势分析总结

## 7. 图表数据

### 7.1 图表图像数据
- `mainChart`: 主图表
- `departmentDetailsChart`: 部门详情图表
- `salaryRangeChart`: 薪资区间图表
- `salaryStructureChart`: 薪资结构图表
- `employeeCountPerMonthChart`: 每月员工数量趋势图
- `averageSalaryPerMonthChart`: 每月平均工资趋势图
- `totalSalaryPerMonthChart`: 每月工资总额趋势图
- `departmentDetailsPerMonthChart`: 每月部门详情趋势图
- `departmentMonthOverMonthChart`: 部门环比变化图表
- `departmentYearOverYearChart`: 部门同比变化图表
- `positionMonthOverMonthChart`: 岗位环比变化图表
- `positionYearOverYearChart`: 岗位同比变化图表