require_relative "../src/ballclock"
require "test/unit"
require "json"

class TestBallClock < Test::Unit::TestCase
  def testInput
    assert_false(Validator.validBallInput?(26))
    assert_false(Validator.validBallInput?(-1))
    assert_false(Validator.validBallInput?(128))
    assert_false(Validator.validBallInput?("a"))
    assert_true(Validator.validBallInput?(27))
    assert_true(Validator.validBallInput?(127))

    assert_false(Validator.validDuration?(-1))
    assert_false(Validator.validDuration?("b"))
    assert_true(Validator.validDuration?(40))
  end
  
  def testNewClockWithBadBallCount
    ex = assert_raise(ArgumentError) { BallClock.new(-1) }
    assert_equal(Validator.invalidBallInput, ex.message)
    ex = assert_raise(ArgumentError) { BallClock.new(26) }
    assert_equal(Validator.invalidBallInput, ex.message)
    ex = assert_raise(ArgumentError) { BallClock.new(128) }
    assert_equal(Validator.invalidBallInput, ex.message)
  end

  def testNewClockWithBadDuration
    ex = assert_raise(ArgumentError) { BallClock.new(30, "a") }
    assert_equal(Validator.invalidDuration, ex.message)
    ex = assert_raise(ArgumentError) { BallClock.new(30, -1) }
    assert_equal(Validator.invalidDuration, ex.message) 
  end

  def testRunClockElapsedDays
    numBalls = 30
    bc = BallClock.new(numBalls)
    result = bc.runClock
    expected = "#{numBalls} balls cycle for 15 days."
    assert_equal(expected, result)

    numBalls = 45
    bc = BallClock.new(numBalls)
    result = bc.runClock
    expected = "#{numBalls} balls cycle for 378 days."
    assert_equal(expected, result)
  end

  def testRunClockForDuration
    numBalls = 30
    duration = 325
    bc = BallClock.new(numBalls, duration)
    expected = {:Min => [], :FiveMin => [22,13,25,3,7], :Hour => [6,12,17,4,15], :Main => [11,5,26,18,2,30,19,8,24,10,29,20,16,21,28,1,23,14,27,9]}
    result = bc.runClock
    assert_equal(expected.to_json, result)
  end
end
