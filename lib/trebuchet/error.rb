class Trebuchet::Error < StandardError ; end
class Trebuchet::BackendInitializationError < Trebuchet::Error ; end
class Trebuchet::BackendError < Trebuchet::Error ; end