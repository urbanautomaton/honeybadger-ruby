require 'honeybadger/util/lambda'

describe Honeybadger::Util::Lambda do
  subject { described_class }

  describe ".lambda_execution?" do
    def with_env_variable(variable, value)
      original_value = ENV[variable]
      ENV[variable] = value
      yield
      ENV[variable] = original_value
    end

    it "is false if AWS_EXECUTION_KEY is unset" do
      with_env_variable("AWS_EXECUTION_KEY", nil) do
        expect(subject.lambda_execution?).to be_falsey
      end
    end

    it "is true if AWS_EXECUTION_ENV has the AWS_lambda_ prefix" do
      with_env_variable("AWS_EXECUTION_ENV", "AWS_Lambda_java8") do
        expect(subject.lambda_execution?).to be_truthy
      end
    end

    it "is false if AWS_EXECUTION_ENV has a non-lambda value" do
      with_env_variable("AWS_EXECUTION_ENV", "AWS_ECS_EC2") do
        expect(subject.lambda_execution?).to be_falsey
      end
    end
  end

  describe ".normalized_data" do
    before do
      allow(ENV).to receive(:[])
    end

    it "includes all HTTP headers" do
      expect(ENV).to receive(:[]).twice.with("AWS_REGION").and_return("westeros")
      expect(ENV).to receive(:[]).twice.with("AWS_EXECUTION_ENV").and_return("Ruby")
      expect(subject.normalized_data).to eq({
        "runtime" => "Ruby",
        "region" => "westeros"
      })
    end
  end
end
