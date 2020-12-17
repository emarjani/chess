#Board pieces 
class Pawn
    attr_accessor :has_moved, :player, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "Pawn"
    end

    def possible_move?(start, fin, board)
        #The board piece/empty spot located at the 'fin' coordinates
        destination = board[fin[0]][fin[1]]

        #Making sure the player's rook is only making forward movement
        move1 = (@player == "p1") ? 1 : -1
        move2 = (@player == "p1") ? 2 : -2

        #Moving one spot forward
        if start[0]-fin[0] == move1
            #Normal one move forward, if spot is not taken
            if start[1] == fin[1] && destination == "-"
                return true
            #Capture piece diagonally, if there is a piece on the board
            elsif (start[1]-fin[1]).abs == 1 && destination != "-"
                if destination.player != @player
                    return true
                end
            end
        #Moving two spots forward (if it hasnt been moved yet).
        elsif start[0]-fin[0] == move2 && @has_moved == false
            #Make sure its not jumping over any piece)
            mid_index = (start[0]+fin[0])/2
            if start[1] == fin[1] && destination == "-" && board[mid_index][start[1]] == "-"
                return true
            end
        #If none of these conditions met;
        else
            return false
        end            
    end

    def to_s
        if @player == "p1" then return "\u2659" else return "\u265F" end
    end
end

class Knight
    attr_accessor :player, :has_moved, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "Knight"
    end

    def possible_move?(start, fin, board)
        destination = board[fin[0]][fin[1]]

        x = [-2,-1,1,2,2,1,-1,-2]
        y = [-1,-2,-2,-1,1,2,2,1]

        (0..7).each do |i|
            if (start[0]+x[i] == fin[0]) && (start[1]+y[i] == fin[1])
                if destination == "-" || destination.player != @player
                    return true
                end
            end
        end
        return false
    end

    def to_s
        if @player == "p1" then return "\u2658" else return "\u265E" end
    end
end

class King
    attr_accessor :player, :has_moved, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "King"
    end
    
    def possible_move?(start, fin, board)
        destination = board[fin[0]][fin[1]]

        x = [-1,-1,0,1,1,1,0,-1]
        y = [0,1,1,1,0,-1,-1,-1]

        (0..7).each do |i|
            if (start[0]+x[i] == fin[0]) && (start[1]+y[i] == fin[1])
                if destination == "-" || destination.player != @player
                    return true
                end
            end
        end
        return false
    end

    def to_s
        if @player == "p1" then return "\u2654" else return "\u265A" end
    end
end

class Queen
    attr_accessor :player, :has_moved, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "Queen"
    end

    def possible_move?(start, fin, board)
        destination = board[fin[0]][fin[1]]

        #Possible diagonal directions
        x=[-1,1,1,-1]
        y=[-1,1,-1,1]

        #Possible vertical/horizontal directions
        c=[1,-1,0,0]
        d=[0,0,1,-1]

        diff = (start[0]-fin[0]).abs 
        diff2 = (start[0] == fin[0]) ? (start[1]-fin[1]).abs : (start[0]-fin[0]).abs

        (0..3).each do |i|
            #Check if its a diagonal move
            if ((start[0]+(diff*x[i])) == fin[0]) && ((start[1]+(diff*y[i])) == fin[1])
                #Check if path is clear
                temp = [start[0]+x[i], start[1]+y[i]]
                while temp[0] != fin[0]
                    if board[temp[0]][temp[1]] != "-"
                        return false
                    end
                    temp[0] += x[i]
                    temp[1] += y[i]
                end
                if destination == "-" || destination.player != @player
                    return true
                end 
            #Check if its a vertical/horizontal move
            elsif ((start[0]+(diff2*c[i])) == fin[0]) && ((start[1]+(diff2*d[i])) == fin[1])
                #Check if path is clear
                temp = [start[0]+c[i], start[1]+d[i]]
                while (temp[0] != fin[0]) || (temp[1] != fin[1])
                    if board[temp[0]][temp[1]] != "-"
                        return false
                    end
                    temp[0] += c[i]
                    temp[1] += d[i]
                end
                if destination == "-" || destination.player != @player
                    return true
                end 
            end 
        end
        #If not a vertical/horizontal/diagonal move;
        return false
    end

    def to_s
        if @player == "p1" then return "\u2655" else return "\u265B" end
    end
end

class Rook
    attr_accessor :player, :has_moved, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "Rook"
    end

    def possible_move?(start, fin, board)
        destination = board[fin[0]][fin[1]]
        diff = (start[0] == fin[0]) ? (start[1]-fin[1]).abs : (start[0]-fin[0]).abs

        #Possible vertical/horizontal directions
        c=[1,-1,0,0]
        d=[0,0,1,-1]

        (0..3).each do |i|
            if ((start[0]+(diff*c[i])) == fin[0]) && ((start[1]+(diff*d[i])) == fin[1])
                #check if path is clear
                temp = [start[0]+c[i], start[1]+d[i]]
                while (temp[0] != fin[0]) || (temp[1] != fin[1])
                    if board[temp[0]][temp[1]] != "-"
                        return false
                    end
                    temp[0] += c[i]
                    temp[1] += d[i]
                end
                if destination == "-" || destination.player != @player
                    return true
                end
            end
        end
        #If none of these conditions are met;
        return false
        #castling move.
    end

    def to_s
        if @player == "p1" then return "\u2656" else return "\u265C" end
    end
end

class Bishop
    attr_accessor :player, :has_moved, :name
    def initialize(player)
        @player = player
        @has_moved = false
        @name = "Bishop"
    end

    def possible_move?(start, fin, board)
        destination = board[fin[0]][fin[1]]

        x=[-1,1,1,-1]
        y=[-1,1,-1,1]
        diff = (start[0]-fin[0]).abs 

        (0..3).each do |i|
            if ((start[0]+(diff*x[i])) == fin[0]) && ((start[1]+(diff*y[i])) == fin[1])
                #Check if path is clear
                temp = [start[0]+x[i], start[1]+y[i]]
                while temp[0] != fin[0]
                    if board[temp[0]][temp[1]] != "-"
                        return false
                    end
                    temp[0] += x[i]
                    temp[1] += y[i]
                end
                if destination == "-" || destination.player != @player
                    return true
                end 
            end
        end
        return false
    end

    def to_s
        if @player == "p1" then return "\u2657" else return "\u265D" end
    end
end


##### Setting chess pieces for a match.

def setting_pieces()
    #Player 1 pieces
    @K = King.new("p1")
    @Q = Queen.new("p1")

    @K1 = Knight.new("p1")
    @K2 = Knight.new("p1")

    @B1 = Bishop.new("p1")
    @B2 = Bishop.new("p1")

    @R1 = Rook.new("p1")
    @R2 = Rook.new("p1")

    @P1 = Pawn.new("p1")
    @P2 = Pawn.new("p1")
    @P3 = Pawn.new("p1")
    @P4 = Pawn.new("p1")
    @P5 = Pawn.new("p1")
    @P6 = Pawn.new("p1")
    @P7 = Pawn.new("p1")
    @P8 = Pawn.new("p1")

    #Player 2 pieces
    @k = King.new("p2")
    @q = Queen.new("p2")

    @k1 = Knight.new("p2")
    @k2 = Knight.new("p2")

    @b1 = Bishop.new("p2")
    @b2 = Bishop.new("p2")

    @r1 = Rook.new("p2")
    @r2 = Rook.new("p2")

    @p1 = Pawn.new("p2")
    @p2 = Pawn.new("p2")
    @p3 = Pawn.new("p2")
    @p4 = Pawn.new("p2")
    @p5 = Pawn.new("p2")
    @p6 = Pawn.new("p2")
    @p7 = Pawn.new("p2")
    @p8 = Pawn.new("p2")
end