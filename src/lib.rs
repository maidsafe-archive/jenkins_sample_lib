pub mod calculator {
    pub fn add(a: i32, b: i32) -> i32 {
        a + b
    }

    pub fn sub(a: i32, b: i32) -> i32 {
        a - b
    }
}

#[cfg(test)]
mod tests {
    use calculator::add;
    use calculator::sub;

    #[test]
    fn add_correctly_adds_2_integers() {
        assert_eq!(add(2, 2), 4);
    }

    #[test]
    fn sub_correctly_subtracts_2_integers() {
        assert_eq!(sub(6, 2), 4);
    }
}
