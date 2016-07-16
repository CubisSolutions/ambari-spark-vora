CREATE SCHEMA IF NOT EXISTS sha;

drop table if exists  sha.employee;

CREATE TABLE IF NOT EXISTS sha.employee (
employee_id                     int,
full_name                       string,
first_name                      string,
last_name                       string,
position_id                     int,
position_title                  string,
store_id                        int,
department_id                   int,
birth_date                      timestamp,
hire_date                       timestamp,
end_date                        timestamp,
salary                          double,
supervisor_id                   int,
education_level                 string,
marital_status                  string,
gender                          string,
management_role                 string 
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' ;

 