workflow "Issue Doctor" {
    on = "issues"
    resolves = ["Hello World"]
}

action "Hello World" {
    uses = "./issue-doctor"
    args = "Hello GitHub Actions!"
}