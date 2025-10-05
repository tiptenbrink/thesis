#![allow(dead_code, unused_variables)]

use std::{collections::HashMap, fmt::Debug};

#[derive(Debug, Clone, Copy)]
pub struct Activity {
    pub duration: i32,
    pub machine: usize,
    pub index: (usize, usize),
}

#[derive(Clone)]
pub struct Problem {
    pub jobs: Vec<Vec<Activity>>,
    // This information is also contained inside 'jobs', but is useful for creating the constraints
    pub machine_map: HashMap<usize, Vec<(usize, usize)>>,
    pub makespan_ub: i32,
    // For true it's job shop, false it's open shop
    pub ordered: bool,
}

pub fn parse_jsp_osp(instance: String) -> Problem {
    let mut lines = instance.lines();
    let jobs_machines_header = lines.next().expect("Expected 'nb_jobs nb_machines' line");
    assert_eq!(jobs_machines_header, "nb_jobs nb_machines");

    let jobs_machines_line = lines.next().expect("Expected 'nb_jobs nb_machines' line");
    let jobs_machines: Vec<usize> = jobs_machines_line
        .split_whitespace()
        .map(|s| s.parse().expect("Parse error"))
        .collect();
    let task_num = jobs_machines[0];
    let machine_num = jobs_machines[1];
    // println!("job_num: {}, machine_num: {}", task_num, machine_num);

    // Read and process the "Times" section
    let times_line = lines.next().expect("Expected 'Times' line");
    assert_eq!(times_line, "Times");
    let mut processing_time_sum = 0;
    let mut total_job = 0;
    let mut time_cost: Vec<Vec<usize>> = Vec::new();
    for _ in 0..task_num {
        let times: Vec<usize> = lines
            .next()
            .expect("Expected times line")
            .split_whitespace()
            .map(|s| s.parse().expect("Parse error"))
            .collect();
        processing_time_sum += times.iter().sum::<usize>();
        total_job += times.len();
        time_cost.push(times);
    }
    //println!("{:?}", time_cost);

    // Read and process the "Machines" section
    let machines_line = lines.next().expect("Expected 'Machines' line");
    assert_eq!(machines_line, "Machines");
    let mut machine_list: Vec<Vec<usize>> = Vec::new();
    for _ in 0..task_num {
        let machines: Vec<usize> = lines
            .next()
            .expect("Expected machines line")
            .split_whitespace()
            .map(|s| s.parse().expect("Parse error"))
            .collect();
        machine_list.push(machines);
    }
    //println!("{:?}", machine_list);

    let mut machine_map: HashMap<usize, Vec<(usize, usize)>> = HashMap::default();

    let mut makespan_ub: i32 = 0;

    let jobs = time_cost
        .iter()
        .enumerate()
        .zip(machine_list)
        .map(|((job_index, durations), machines)| {
            let tasks: Vec<Activity> = durations
                .iter()
                .enumerate()
                .zip(machines)
                .map(|((task_index, duration), machine)| {
                    let activity_index = (job_index, task_index);
                    if let Some(machine_tasks) = machine_map.get_mut(&machine) {
                        machine_tasks.push(activity_index);
                    } else {
                        let _ = machine_map.insert(machine, vec![activity_index]);
                    }
                    let duration_int = *duration as i32;
                    makespan_ub += duration_int;

                    Activity {
                        duration: duration_int,
                        machine,
                        index: activity_index,
                    }
                })
                .collect();

            tasks
        })
        .collect::<Vec<Vec<Activity>>>();

    Problem {
        jobs,
        machine_map,
        makespan_ub,
        ordered: true,
    }
}

impl Debug for Problem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "Problem (<duration>:<machine>).")?;

        for (j_i, job) in self.jobs.iter().enumerate() {
            for (a_i, activity) in job.iter().enumerate() {
                write!(f, "{:>3}:{:>3}  ", activity.duration, activity.machine)?;
            }
            writeln!(f)?;
        }

        let mut keys: Vec<_> = self.machine_map.keys().cloned().collect();
        keys.sort();

        for m_i in keys {
            write!(f, "Machine {}: ", m_i)?;
            f.debug_list().entries(&self.machine_map[&m_i]).finish()?;
            writeln!(f)?;
        }

        Ok(())
    }
}
