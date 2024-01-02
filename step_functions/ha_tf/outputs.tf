output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.example.invoke_url
}

output "state_machine_human_approval_arn" {
  value = aws_sfn_state_machine.example_state_machine.arn
}