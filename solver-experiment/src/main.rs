#![allow(dead_code, unused_variables)]
mod uip;
mod model;

use std::{
    collections::{HashMap, HashSet, VecDeque}, fmt::Debug, fs, path::Path
};

use model::{parse_jsp_osp, Problem};

fn index_to_var_id(index: (usize, usize)) -> u64 {
    let (i, j) = index;
    assert!(i < 256);
    assert!(j < 256);
    ((i as u64) << 8) + (j as u64)
}

fn var_id_to_index(id: u64) -> (usize, usize) {
    assert!(id < const { 2u64.pow(16) });
    let i = (id >> 8) as usize;
    // 255 is 1111111, so it is a mask for the least significant bits
    let j = (id & 255) as usize;

    (i, j)
}

const VAR_ID_LIMIT: u64 = const { 2u64.pow(16) };

fn var_ids_to_precedence_id(var_before: u64, var_after: u64) -> u64 {
    // The var_id is inside 16 bits, so we just put both side by side
    assert!(var_before < VAR_ID_LIMIT);
    assert!(var_after < VAR_ID_LIMIT);

    (var_before << 16) + var_after
}

fn var_ids_to_no_overlap_id(var_1: u64, var_2: u64) -> u64 {
    assert!(var_1 < VAR_ID_LIMIT);
    assert!(var_2 < VAR_ID_LIMIT);

    (1 << 17) + (var_1 << 16) + var_2
}

fn build_model(p: &Problem) -> Model {
    let mut model = Model::new();

    for activities in &p.jobs {
        for a in activities.windows(2) {
            if a.len() != 2 {
                continue;
            }

            let a1 = &a[0];
            let a2 = &a[1];

            let a1_var_id = index_to_var_id(a1.index);
            let a2_var_id = index_to_var_id(a2.index);

            // We can reduce the bounds by a bit based on the fact they have an ordering
            if a1.index.1 == 0 {
                model.create_bounded_variable(a1_var_id, 0, p.makespan_ub - a2.duration - a1.duration);
            }
            model.create_bounded_variable(a2_var_id, 0, p.makespan_ub - a2.duration);

            // start_time_1 + duration_1 <= start_time_2
            // ->>
            // start_time_1 - start_time_2 <= -duration_1
            let constraint_id = var_ids_to_precedence_id(a1_var_id, a2_var_id);
            model.post_lin_ineq_lt(
                constraint_id,
                &[Literal::id(a1_var_id), Literal::id_neg(a2_var_id)],
                -a1.duration,
            );
        }
    }

    for (m, m_activities) in &p.machine_map {
        for (a1, a2) in m_activities.iter().enumerate().flat_map(|(i, a_first)| {
            m_activities
                .iter()
                .skip(i + 1)
                .map(|a_other| (*a_first, *a_other))
                .collect::<Vec<((usize, usize), (usize, usize))>>()
        }) {
            let a1 = &p.jobs[a1.0][a1.1];
            let a2 = &p.jobs[a2.0][a2.1];

            let a1_var_id = index_to_var_id(a1.index);
            let a2_var_id = index_to_var_id(a2.index);

            let constraint_id = var_ids_to_no_overlap_id(a1_var_id, a2_var_id);
            model.no_overlap(
                constraint_id,
                a1_var_id,
                a2_var_id,
                a1.duration,
                a2.duration,
            );
        }
    }

    model
}

fn main() {
    let path = Path::new("instances/jsp/tiny_larger.jsp");
    let s = fs::read_to_string(path).unwrap();

    let p = parse_jsp_osp(s);

    let model = build_model(&p);

    let n = model.variables.values().fold(0, |s, v| {
        if v.domain.is_empty() {
            s
        } else {
            s + (v.domain.last().unwrap() - v.domain.first().unwrap())
        }
    });

    println!("n={}", n);

    //println!("{:?}", model.variables.iter().map(|v| (v.1.id, &v.1.domain)).collect::<Vec<(u64, &Vec<i32>)>>());


    let result = solve(model);

    if let Some(result) = result {
        println!("{:?}", result.variables.iter().map(|v| (v.1.id, &v.1.domain)).collect::<Vec<(u64, &Vec<i32>)>>());
    } else {
        println!("UNSAT!")
    }

    //println!("{:?}", p);
}

#[derive(Clone)]
struct Variable {
    id: u64,
    // INVARIANT: this is ordered
    domain: Vec<i32>,
}

impl Variable {
    fn new_bounded(id: u64, lb: i32, ub: i32) -> Self {
        assert!(lb <= ub);

        let range: Vec<i32> = (lb..=ub).collect();

        Self { id, domain: range }
    }
}

#[derive(Clone, Copy)]
struct Literal {
    id: u64,
    // true means positive, false means negative
    sign: bool,
}

impl Literal {
    fn id(id: u64) -> Self {
        Self { id, sign: true }
    }

    fn id_neg(id: u64) -> Self {
        Self { id, sign: false }
    }
}

#[derive(Clone)]
struct NoOverlap {
    id: u64,
    vars: (u64, u64),
    durations: (i32, i32),
}

impl Debug for NoOverlap {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "`no_overlap` 1=`{}` d1={} 2=`{}` d2={}", self.vars.0, self.durations.0, self.vars.1, self.durations.1)
    }
}

struct Assignment {
    map: HashMap<u64, i32>,
}

impl Assignment {
    fn value(&self, var_id: u64) -> i32 {
        *self.map.get(&var_id).unwrap()
    }
}

impl NoOverlap {
    fn new(id: u64, var_1_id: u64, var_2_id: u64, duration_1: i32, duration_2: i32) -> Self {
        assert!(duration_1 >= 0);
        assert!(duration_2 >= 0);

        Self {
            id,
            vars: (var_1_id, var_2_id),
            durations: (duration_1, duration_2),
        }
    }

    fn evaluate(&self, var_1: i32, var_2: i32) -> bool {
        let (d1, d2) = self.durations;

        (var_1 + d1 <= var_2) || (var_2 + d2 <= var_1)
    }
}

trait CheckableConstraint {
    fn check_assignment(&self, assignment: &Assignment) -> bool;

    fn check_domain(&self, variables: &HashMap<u64, Variable>) -> bool;
}

impl CheckableConstraint for NoOverlap {
    fn check_assignment(&self, assignment: &Assignment) -> bool {
        let var_1 = assignment.value(self.vars.0);
        let var_2 = assignment.value(self.vars.1);

        self.evaluate(var_1, var_2)
    }

    fn check_domain(&self, variables: &HashMap<u64, Variable>) -> bool {
        let (var_1_id, var_2_id) = self.vars;

        let var_1_domain = &variables.get(&var_1_id).unwrap().domain;
        let var_2_domain = &variables.get(&var_2_id).unwrap().domain;

        for var_1 in var_1_domain {
            for var_2 in var_2_domain {
                if self.evaluate(*var_1, *var_2) {
                    // println!(
                    //     "no_overlap: {}={}+{}; {}={}+{}",
                    //     var_1_id, var_1, self.durations.0, var_2_id, var_2, self.durations.1
                    // );
                    return true;
                }
            }
        }

        return false;
    }
}

#[derive(Clone)]
struct LinIneqLt {
    id: u64,
    lhs: Vec<Literal>,
    rhs: i32,
}

impl LinIneqLt {
    fn new(id: u64, literals: &[Literal], rhs: i32) -> Self {
        Self {
            id,
            lhs: literals.to_vec(),
            rhs,
        }
    }

    fn evaluate(&self, values: &Vec<i32>) -> i32 {
        let lhs_sum = self.lhs.iter().enumerate().fold(0, |sum, (var_i, l)| {
            // 2 * x - 1 maps 1 to 1 and 0 to -1
            sum + values[var_i] * (2 * (l.sign as i32) - 1)
        });

        lhs_sum
    }
}

impl CheckableConstraint for LinIneqLt {
    fn check_assignment(&self, assignment: &Assignment) -> bool {
        let values = self.lhs.iter().map(|l| assignment.value(l.id)).collect();
        let lhs_sum = self.evaluate(&values);

        lhs_sum <= self.rhs
    }

    fn check_domain(&self, variables: &HashMap<u64, Variable>) -> bool {
        let domains: Vec<&Vec<i32>> = self
            .lhs
            .iter()
            .map(|l| &variables.get(&l.id).unwrap().domain)
            .collect();
        let mut indexes = vec![0; domains.len()];
        let mut assignment: Vec<i32> = indexes
            .iter()
            .enumerate()
            .map(|(var_i, domain_i)| domains[var_i][*domain_i])
            .collect();
        
        let mut old_value = *assignment.last().unwrap();
        let mut assignment_sum: i32 = self.evaluate(&assignment);
        let mut changed_var = assignment.len() - 1;

        //println!("assignment={:?}, sum={}", assignment, assignment_sum);
        'outer: loop {
            let new_index = indexes[changed_var];
            let new_value = domains[changed_var][new_index];
            let sign = 2 * (self.lhs[changed_var].sign as i32) - 1;
            assignment[changed_var] = new_value;
            assignment_sum += sign * (new_value - old_value);
            //println!("assignment={:?}, sum={}", assignment, assignment_sum);
            if assignment_sum <= self.rhs {
                return true;
            }

            // We try to increase the index back to front
            for var_i in (0..indexes.len()).rev() {
                let domain = domains[var_i];
                let index = indexes[var_i];
                //println!("domain={:?} for var={} with i={}", domain, var_i, index);
                // If index hasn't reached max, we increase it
                if index != domain.len() - 1 {
                    old_value = domain[index];
                    changed_var = var_i;
                    indexes[var_i] += 1;

                    continue 'outer;
                }
            }
            break;
        }

        //println!("Could not satisfy {}*`{}` + {}*`{}` <= {}; d1={:?}, d2={:?}", ((self.lhs[0].sign as i32) * 2 - 1), self.lhs[0].id,  ((self.lhs[1].sign as i32) * 2 - 1), self.lhs[1].id, self.rhs, variables.get(&self.lhs[0].id).unwrap().domain, variables.get(&self.lhs[1].id).unwrap().domain);
        false
    }
}

impl Debug for LinIneqLt {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "`lin` {}*`{}` + {}*`{}` <= {}", ((self.lhs[0].sign as i32) * 2 - 1), self.lhs[0].id,  ((self.lhs[1].sign as i32) * 2 - 1), self.lhs[1].id, self.rhs)
    }
}

#[derive(Clone, Debug)]
enum Constraint {
    NoOverlap(NoOverlap),
    LinIneqLt(LinIneqLt),
}

impl CheckableConstraint for Constraint {
    fn check_assignment(&self, assignment: &Assignment) -> bool {
        match self {
            Constraint::NoOverlap(no_overlap) => no_overlap.check_assignment(assignment),
            Constraint::LinIneqLt(lin_ineq_lt) => lin_ineq_lt.check_assignment(assignment),
        }
    }

    fn check_domain(&self, variables: &HashMap<u64, Variable>) -> bool {
        match self {
            Constraint::NoOverlap(no_overlap) => no_overlap.check_domain(variables),
            Constraint::LinIneqLt(lin_ineq_lt) => lin_ineq_lt.check_domain(variables),
        }
    }
}

fn propagate_check_constraint(constraint_id: u64, model: &mut Model, print: bool) -> bool {
    let constraint = model.constraints.get(&constraint_id).unwrap();
    if print {
        println!("Checking {:?}", constraint);
    }

    constraint.check_domain(&model.variables)
}

#[derive(Clone)]
enum Propagator {
    CheckConstraint(u64),
}

impl Propagator {
    fn propagate(&self, model: &mut Model, print: bool) -> bool {
        let valid = match self {
            Propagator::CheckConstraint(constraint_id) => {
                propagate_check_constraint(*constraint_id, model, print)
            }
        };

        valid
    }
}

#[derive(Clone)]
struct Model {
    variables: HashMap<u64, Variable>,
    variable_constraints: HashMap<u64, HashSet<u64>>,
    constraints: HashMap<u64, Constraint>,
    propagator_queue: VecDeque<Propagator>,
}

impl Model {
    fn new() -> Self {
        Self {
            variables: HashMap::new(),
            variable_constraints: HashMap::new(),
            constraints: HashMap::new(),
            propagator_queue: VecDeque::new(),
        }
    }

    fn create_bounded_variable(&mut self, id: u64, lb: i32, ub: i32) {
        self.variables.insert(id, Variable::new_bounded(id, lb, ub));
    }

    fn register_constraint_for_variable(&mut self, variable_id: u64, constraint_id: u64) {
        self.variable_constraints
            .entry(variable_id)
            .or_default()
            .insert(constraint_id);
    }

    fn no_overlap(
        &mut self,
        id: u64,
        var_1_id: u64,
        var_2_id: u64,
        duration_1: i32,
        duration_2: i32,
    ) {
        self.constraints.insert(
            id,
            Constraint::NoOverlap(NoOverlap::new(
                id, var_1_id, var_2_id, duration_1, duration_2,
            )),
        );
        self.register_constraint_for_variable(var_1_id, id);
        self.register_constraint_for_variable(var_2_id, id);
        self.propagator_queue
            .push_front(Propagator::CheckConstraint(id));
    }

    fn post_lin_ineq_lt(&mut self, id: u64, literals: &[Literal], rhs: i32) {
        self.constraints
            .insert(id, Constraint::LinIneqLt(LinIneqLt::new(id, literals, rhs)));
        for l in literals {
            self.register_constraint_for_variable(l.id, id);
        }
        self.propagator_queue
            .push_front(Propagator::CheckConstraint(id));
    }

    fn propagate_queue(&mut self, print: bool) -> bool {
        while !self.propagator_queue.is_empty() {
            let propagator = self.propagator_queue.pop_back().unwrap();

            if !propagator.propagate(self, print) {
                return false;
            }
        }

        return true;
    }

    fn check_solution() {}
}

fn brute_force(model: &mut Model) {}

enum DivideResult {
    Divided((Model, Model)),
    Finished(Model)
}

fn divide(mut model: Model) -> DivideResult {
    
    let mut variables = model.variables.keys();

    let branch_variable = loop {
        let variable = variables.next();
        if let Some(variable) = variable {
            if model.variables.get(variable).unwrap().domain.len() > 1 {
                break *variable;
            }
            // we continue in this case
        } else {
            return DivideResult::Finished(model);
        }
    };
    let constraints: Vec<u64> = model.variable_constraints.get(&branch_variable).map(|c| c.iter().map(|c| *c).collect()).unwrap_or_default();
    for c in constraints {
        model.propagator_queue.push_front(Propagator::CheckConstraint(c));
    }

    let mut model_1 = model.clone();
    let mut model_2 = model;


    let domain = &mut model_2.variables.get_mut(&branch_variable).unwrap().domain;
    // We know length >= 2
    let other_domain = domain.split_off(domain.len() / 2);
    let var_model_1 = model_1.variables.get_mut(&branch_variable).unwrap();
    var_model_1.domain = other_domain;

    DivideResult::Divided((model_1, model_2))
}

fn solve(model: Model) -> Option<Model> {
    let mut model_queue = VecDeque::new();
    model_queue.push_back(model);

    while !model_queue.is_empty() {
        let mut model = model_queue.pop_back().unwrap();
        if !model.propagate_queue(false) {
            //println!("domains unsat={:?}", model.variables.iter().map(|v| (v.1.id, &v.1.domain)).collect::<Vec<(u64, &Vec<i32>)>>());

            continue;
        }

        match divide(model) {
            DivideResult::Divided((model_1, model_2)) => {
                //println!("split1={:?}", model_1.variables.iter().map(|v| (v.1.id, &v.1.domain)).collect::<Vec<(u64, &Vec<i32>)>>());
                //println!("split2={:?}", model_2.variables.iter().map(|v| (v.1.id, &v.1.domain)).collect::<Vec<(u64, &Vec<i32>)>>());

                model_queue.push_back(model_1);
                model_queue.push_back(model_2);
            },
            DivideResult::Finished(mut model) => {
                // sanity
                for c in model.constraints.keys() {
                    model.propagator_queue.push_back(Propagator::CheckConstraint(*c));
                }
                assert!(model.propagate_queue(false));

                return Some(model);
            },
        }

    }

    return None;
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;

    use crate::{CheckableConstraint, LinIneqLt, Literal, NoOverlap, Variable};

    #[test]
    fn test_no_overlap() {
        let no_overlap = NoOverlap::new(0, 0, 1, 5, 7);
        let mut variables = HashMap::new();
        let var_1 = Variable::new_bounded(0, 0, 5);
        let var_2 = Variable::new_bounded(1, 0, 5);
        variables.insert(0, var_1);
        variables.insert(1, var_2);
        assert!(no_overlap.check_domain(&variables))
    }

    #[test]
    fn test_lin() {
        let lin = LinIneqLt::new(0, &vec![Literal::id(0), Literal::id_neg(1)], -5);
        let mut variables = HashMap::new();
        let var_1 = Variable::new_bounded(0, 0, 5);
        let var_2 = Variable::new_bounded(1, 0, 5);
        variables.insert(0, var_1);
        variables.insert(1, var_2);
        assert!(lin.check_domain(&variables))
    }

    #[test]
    fn test_lin_adv() {
        let lin = LinIneqLt::new(0, &vec![Literal::id(0), Literal::id_neg(1)], -1);
        let mut variables = HashMap::new();
        let var_1 = Variable::new_bounded(0, 0, 0);
        let var_2 = Variable::new_bounded(1, 2, 3);
        variables.insert(0, var_1);
        variables.insert(1, var_2);
        assert!(lin.check_domain(&variables))
    }

}
