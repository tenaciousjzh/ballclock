require 'json'

class BallClock
  @@minTrackCapacity = 4
  @@fiveMinTrackCapacity = 11
  @@hourTrackCapacity = 11
  
  def initialize(numBalls, durationMinutes = 0)
    if not Validator.validBallInput?(numBalls)
      raise ArgumentError, Validator.invalidBallInput, caller
    end
    if not Validator.validDuration?(durationMinutes)
      raise ArgumentError, Validator.invalidDuration, caller
    end
    
    @numBalls = numBalls
    @ballq = loadBallQueue(numBalls)
    @orig = @ballq.clone
    @minTrack = []
    @fiveMinTrack = []
    @hourTrack = []
    @halfDays = 0
    @fullDays = 0

    @minCount = 0
    @fiveMinCount = 0
    @hourCount = 0
    
    @mode = :reportdays
    @debug = false
    
    if durationMinutes > 0
      @mode = :reporttracks
      @duration = durationMinutes
    end
  end

  def loadBallQueue(size)
    ballq = []
    for i in 0...size
      ballq[i] = i+1
    end
    return ballq
  end
  private :loadBallQueue

  def runClock()
    if @mode == :reportdays
      return simulateDays()
    else
      return simulateDuration()
    end
  end
  
  def simulateDays()
    @halfDays = 0
    counter = 0
    loop do
      ballVal = @ballq.shift
      minTrack(ballVal)
      counter += 1
      break if  @orig == @ballq
    end
    
    @fullDays = @halfDays / 2
    return "#{@numBalls} balls cycle for #{@fullDays} days."
  end
  private :simulateDays
  
  def simulateDuration()
    counter = 0
    for i in 0...@duration
      ballVal = @ballq.shift
      minTrack(ballVal)
      counter += 1
    end
    result = {:Min => @minTrack, :FiveMin => @fiveMinTrack, :Hour => @hourTrack, :Main => @ballq}
    json = result.to_json
    return "#{json}"
  end
  private :simulateDuration
  
  def printCounts(ballVal)
    if @debug
      puts "ballVal: #{ballVal}"
      puts "minCount: #{@minCount}, fiveMinCount: #{@fiveMinCount}, hourCount: #{@hourCount}"
      puts "halfDays: #{@halfDays}"
      puts self
    end
  end
  
  def minTrack(ballVal)
    @minCount += 1
    if @minTrack.length == @@minTrackCapacity
      # Put the balls on the track in reverse order
      # back into ballq
      for i in 0...@minTrack.length
        @ballq.push(@minTrack.pop)
      end
      # Put the next ball from ballq into the next track
      fiveMinTrack(ballVal)
    else
      @minTrack.push(ballVal)
    end
  end
  private :minTrack
  
  def fiveMinTrack(ballVal)
    @fiveMinCount += 1
    if @fiveMinTrack.length == @@fiveMinTrackCapacity
      for i in 0...@fiveMinTrack.length
        @ballq.push(@fiveMinTrack.pop)
      end
      hourTrack(ballVal)
    else
      @fiveMinTrack.push(ballVal)
    end
  end
  private :fiveMinTrack
  
  def hourTrack(ballVal)
    @hourCount += 1
    if @hourTrack.length == @@hourTrackCapacity
      for i in 0...@hourTrack.length
        @ballq.push(@hourTrack.pop)
      end
      @ballq.push(ballVal)
      @halfDays += 1
      printCounts(ballVal)
    else
      @hourTrack.push(ballVal)
    end
  end
  private :hourTrack
  
  def to_s
    output = "Ball Queue: #{@ballq}\n"
    output += "Minute Track: #{@minTrack}\n"
    output += "Five Minute Track: #{@fiveMinTrack}\n"
    output += "Hour Track: #{@hourTrack}\n"
    output += "Mode: #{@mode}\n"
    return output
  end

end

class Validator
  @@min = 27
  @@max = 127
  
  def self.validBallInput?(input)
    if input.is_a? String
      return false
    end
    if input == 0 or input < @@min or input > @@max
      return false
    end
    return true
  end

  def self.validDuration?(input)
    if input.is_a? String
      return false
    end

    if input < 0
      return false
    end
    return true
  end
  
  def self.invalidBallInput
    return "The first parameter must be a number between 27 and 127"
  end
  
  def self.invalidDuration
    return "The second parameter must be a number greater than 0"
  end
end


if __FILE__ == $0
  numBalls = (ARGV[0] || 0).to_i
  
  if not Validator.validBallInput?(numBalls)
    puts Validator.invalidBallInput
    exit 1
  end

  duration = (ARGV[1] || 0).to_i
 
  ballClock = BallClock.new(numBalls, duration)
  puts ballClock.runClock()
  
end 
