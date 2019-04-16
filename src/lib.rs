pub mod calculator {
    pub fn add(a: i32, b: i32) -> i32 {
        a + b
    }
}

#[cfg(test)]
mod tests {
    use calculator::add;

    #[test]
    fn add_correctly_adds_2_integers() {
        assert_eq!(add(2, 2), 4);
    }
}
