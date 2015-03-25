use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :extris_web, ExtrisWeb.Endpoint,
  secret_key_base: "nSf9Vq+P9tQw9xaNeVY/+mbJFXDZLV/2ZhPUEEN5lZXJB1+ITlIUuctJ6/vWLRRk"

# Configure your database
config :extris_web, ExtrisWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "extris_web_prod"
