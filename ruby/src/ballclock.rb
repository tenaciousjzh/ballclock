
class BallClock
  @@minTrackCapacity = 4
  @@fiveMinTrackCapacity = 11
  @@hourTrackCapacity = 11
  
  def initialize(numBalls, durationMinutes)
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
    puts "#{@numBalls} balls cycle for #{@fullDays} days."
  end

  def printCounts(ballVal)
    puts "ballVal: #{ballVal}"
    puts "minCount: #{@minCount}, fiveMinCount: #{@fiveMinCount}, hourCount: #{@hourCount}"
    puts "halfDays: #{@halfDays}"
    puts self
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

def validInput?(input)
  if input == 0 or input < 27 or input > 127
    return false
  end
  return true
end

if __FILE__ == $0
  numBalls = (ARGV[0] || 0).to_i
  
  if not validInput?(numBalls)
    puts "The first parameter must be a number between 27 and 127"
    exit(false)
  end

  if not ARGV[1].nil? and not validInput?(ARGV[1].to_i)
    puts "The second parameter must be a number between 27 and 127"
    exit(false)
  end
  
  duration = (ARGV[1] || 0).to_i
 
  ballClock = BallClock.new(numBalls, duration)
  ballClock.simulateDays()
  
  puts ballClock
  
end 
