[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[inputs.prometheus]]
  urls = ["http://127.0.0.1:8200/v1/sys/metrics?format=prometheus"]
  metric_version = 2

[[inputs.http_response]]
  name_override = "vault_health"
  urls = ["http://127.0.0.1:8200/v1/sys/health"]
  method = "GET"
  response_timeout = "5s"
  follow_redirects = true

[[inputs.http]]
  name_override = "vault_replication"
  urls = ["http://127.0.0.1:8200/v1/sys/replication/status"]
  method = "GET"
  response_timeout = "5s"
  data_format = "json_v2"

  [[inputs.http.json_v2]]
    [[inputs.http.json_v2.tag]]
      path = "data.dr.mode"
      rename = "dr_mode"
      optional = true

    [[inputs.http.json_v2.tag]]
      path = "data.dr.state"
      rename = "dr_state"
      optional = true

    [[inputs.http.json_v2.tag]]
      path = "data.performance.mode"
      rename = "perf_mode"
      optional = true

    [[inputs.http.json_v2.tag]]
      path = "data.performance.state"
      rename = "perf_state"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.dr.last_wal"
      rename = "dr_last_wal"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.dr.last_dr_wal"
      rename = "dr_last_dr_wal"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.performance.last_wal"
      rename = "perf_last_wal"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.performance.last_performance_wal"
      rename = "perf_last_performance_wal"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.dr.ssct_generation_counter"
      rename = "dr_ssct_generation_counter"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.performance.ssct_generation_counter"
      rename = "perf_ssct_generation_counter"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.dr.secondaries.#"
      rename = "dr_secondaries_count"
      type = "int"
      optional = true

    [[inputs.http.json_v2.field]]
      path = "data.performance.secondaries.#"
      rename = "perf_secondaries_count"
      type = "int"
      optional = true

[[outputs.azure_monitor]]
  namespace_prefix = "vault/"
  strings_as_dimensions = false
  timeout = "20s"
