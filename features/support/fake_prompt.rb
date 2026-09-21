class FakePrompt
  def initialize(responses)
    @responses = responses
  end

  def select(_message, _choices)
    @responses.shift
  end

  def ask(_message)
    @responses.shift
  end
end