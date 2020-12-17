require "./chess_pieces"
require "yaml"

#Game logic
class Chess
    attr_accessor :board

    def initialize
        setting_pieces()
        settings()
    end

    def settings
        @rounds = 1
        @board = [
            [@r1,@k1,@b1,@q,@k,@b2,@k2,@r2],
            [@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8],
            ["-","-","-","-","-","-","-","-"],
            ["-","-","-","-","-","-","-","-"],
            ["-","-","-","-","-","-","-","-"],
            ["-","-","-","-","-","-","-","-"],
            [@P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8],
            [@R1,@K1,@B1,@Q,@K,@B2,@K2,@R2]
        ]
        
        @last_move = []
    end

    def draw_board(board = @board)
        board_format = [
            [" ","a","b","c","d","e","f","g","h"," "],
            ["8", nil, "8"],
            ["7", nil, "7"],
            ["6", nil, "6"],
            ["5", nil, "5"],
            ["4", nil, "4"],
            ["3", nil, "3"],
            ["2", nil, "2"],
            ["1", nil, "1"],
            [" ","a","b","c","d","e","f","g","h"," "]
        ]
        (1..8).each do |i|
            board_format[i][1] = @board[i-1]
        end
        board_format.each do |row|
            puts row.join(" ")
        end
    end

    def startMenu
        puts "Welcome to Chess!\n\n"
        puts "1. New round\n2. Load saved game\n"
        puts "\n(To exit or save at any point in the match, enter 'exit'/'save' respectively.)"

        input = gets.chomp
        if input == "1"
            startRound()
        elsif input == "2"
            load_game()
        else
            exit
        end
    end

    def startRound
        @current_player = (@rounds % 2 == 0)? "p2" : "p1"
        @players_king = (@rounds % 2 == 0)? @k : @K
        @winner = (@current_player == "p1")? "Player 2" : "Player 1"

        puts "\nRound #{@rounds}:\n"
        draw_board()
        state_of_game()
        
        puts "Enter move: "
        input = gets.chomp

        if input == "exit"
            exit
        elsif input == "save"
            save_game()
            puts "Game saved!"
            exit
        end

        if valid_input?(input)
            input = input.split(" ")
            start = translate_code(input[0])
            fin = translate_code(input[2])
            make_move(start, fin)
        else
            puts "Mistake in input!"
        end
        startRound()
    end
 
    def state_of_game
        #If king isn't found (player's king already dead)
        if find_king(@players_king) == []
            puts "#{@winner} wins!"
            exit
        else
            #Check for checkmate/check.
            if in_check?(@players_king)
                if is_checkmate?(@players_king)
                    puts "Checkmate!"
                    puts "#{@winner} wins!"
                    exit
                else
                    puts "Check"
                end
            end
        end
    end

    def valid_input?(input) #(input should have the format 'a2 to a3')
        input = input.downcase.split(" ")
        if input.length != 3
            return false
        end
        return input[1] == "to" && valid_code?(input[0]) && valid_code?(input[2])
    end

    def valid_code?(input)
        valid_letters = ["a","b","c","d","e","f","g","h"]
        valid_nums = ["1","2","3","4","5","6","7","8"]

        if input.length != 2
            puts "Please enter valid input!"
            return false
        end
        input = input.downcase.split("")
        if valid_letters.include?(input[0]) && valid_nums.include?(input[1])
            return true
        end
        return false
    end

    def translate_code(input)
        input = input.downcase.split("")
        letter = {"a"=>0,"b"=>1,"c"=>2,"d"=>3,"e"=>4,"f"=>5,"g"=>6,"h"=>7}
        number = {"8"=>0,"7"=>1,"6"=>2,"5"=>3,"4"=>4,"3"=>5,"2"=>6,"1"=>7}
        #returns board 'list' indices for a specific board position
        return [number[input[1]], letter[input[0]]]
    end

    def make_move(start, fin)
        current_piece = @board[start[0]][start[1]]

        if current_piece == "-"
            puts "Selected an empty square!"
        else
            if current_piece.player != @current_player
                puts "Select your piece!"
            else
                #Check if move is en passant
                if en_passant?(start, fin)
                    en_passant_move(start, fin)
                    @rounds += 1
                    @last_move = [start, fin]

                #Check if moves is a castling move
                elsif castle?(start, fin)
                    castle_move(start, fin)
                    @rounds += 1
                    @last_move = [start, fin]

                #Check other possible "regular" moves
                elsif current_piece.possible_move?(start, fin, @board) 
                    #Check promotion (if current piece is a pawn)
                    if current_piece.name == "Pawn"
                        promotion?(start, fin, current_piece)
                    end

                    @board[fin[0]][fin[1]] = @board[start[0]][start[1]]
                    current_piece.has_moved = true
                    @board[start[0]][start[1]] = "-"
                    @rounds += 1
                    @last_move = [start, fin]  
                else
                    puts "Not a valid move!"
                end
            end
        end
    end

    def find_king(king)
        king_indexes = []
        (0..7).each do |i|
            (0..7).each do |z|
                if board[i][z] == king
                    king_indexes.push(i, z)
                end
            end
        end
        return king_indexes
    end

    ########## CHECK AND CHECKMATE ################################################

    def in_check?(king, board = @board)
        #Locate king's coordinates
        king_indexes = find_king(king)
        temp = [king_indexes[0], king_indexes[1]]

        #CHECK HORIZONTAL/VERICAL
        pos = [-1, 1]

        (0..1).each do |i| #determines part of board(vertical/horizontal)
            (0..1).each do |z| # this will be the index -1, 1
                catch :not_checked do
                    while (temp[i]+pos[z]).between?(0,7)
                        temp[i] += pos[z]
                        piece = board[temp[0]][temp[1]]
                        if piece != "-"
                            if piece.player != king.player
                                if piece.name == "Queen" || piece.name == "Rook"
                                    return true
                                elsif piece.name == "King" && ((temp[i]-king_indexes[i]).abs == 1)
                                    return true
                                end
                                #board piece of opposite class, but not queen rook or king.
                            end
                            #Board piece is same player as king
                            temp[i] = king_indexes[i]
                            throw :not_checked
                        end
                    end
                end
                #Board is completely blank on one side, so reset indexes
                temp[i] = king_indexes[i]
            end
        end
        #CHECK DIAGONAL 
        x=[-1,1,1,-1]
        y=[-1,1,-1,1]
        forward = (king.player == "p1")? -1 : 1

        (0..3).each do |i|
            catch :not_checked do 
                while (temp[0]+x[i]).between?(0,7) && (temp[1]+y[i]).between?(0,7)
                    temp[0] += x[i]
                    temp[1] += y[i]
                    piece = board[temp[0]][temp[1]]
                    if piece != "-"
                        if piece.player != king.player
                            if piece.name == "Queen" || piece.name == "Bishop"
                                return true
                            elsif piece.name == "King" && (temp[0]-king_indexes[0]).abs == 1
                                return true
                            elsif (piece.name == "Pawn")
                                #make sure step is forward and only moving by one spot
                                if (x[i] == forward) && (temp[0]-king_indexes[0]).abs == 1 
                                    return true
                                end
                            end
                        end
                        temp[0] = king_indexes[0]
                        temp[1] = king_indexes[1]
                        throw :not_checked
                    end
                end
            end
            temp[0] = king_indexes[0]
            temp[1] = king_indexes[1]
        end
        #CHECK KNIGHT
        c = [-2,-1,1,2,2,1,-1,-2]
        d = [-1,-2,-2,-1,1,2,2,1]

        (0..7).each do |i|
            #is move valid?(on the board)
            if (temp[0]+c[i]).between?(0, 7) && (temp[1]+d[i]).between?(0, 7)
                x = temp[0]+c[i]
                y = temp[1]+d[i]
                if board[x][y] != "-"
                    if board[x][y].name == "Knight" && board[x][y].player != king.player
                        return true
                    end
                end
            end
        end
        #If none of these check conditions are met;
        return false
    end

    def is_checkmate?(king)
        #Locate the king's coordinates
        k_indexes = find_king(king)

        x = [-1,-1,0,1,1,1,0,-1]
        y = [0,1,1,1,0,-1,-1,-1]

        #Make copy of original board to later be able to revert all changes.
        temp_board = []
        @board.each{|e| temp_board << e.dup}

        indexes = [k_indexes[0], k_indexes[1]]

        (0..7).each do |i|
            catch :checked do
                if (indexes[0]+x[i]).between?(0,7) && (indexes[1]+y[i]).between?(0,7)
                    indexes[0] += x[i]
                    indexes[1] += y[i]

                    place = temp_board[indexes[0]][indexes[1]]
                    #can occupy space if it is enemy piece or empty else skip
                    if place == "-" || (place.player != king.player)
                        #run check
                        @board[k_indexes[0]][k_indexes[1]] = "-"
                        @board[indexes[0]][indexes[1]] = king
                        draw_board(@board)
                        
                        if in_check?(king, temp_board)
                            #undo move
                            @board = temp_board
                            #reset indices
                            indexes[0] = k_indexes[0]
                            indexes[1] = k_indexes[1]
                            throw :checked
                        else
                            #if king at new position is not checked
                            return false
                        end
                    else #if spot is taken by piece of same player
                        indexes[0] = k_indexes[0]
                        indexes[1] = k_indexes[1]
                        throw :checked
                    end
                end
            end
        end
        return true
    end

    ########## CHESS SPECIAL MOVES ###############################

    def castle?(start, fin) # to castle you pick up the king first.
        piece1 = @board[start[0]][start[1]]
        piece2 = @board[fin[0]][fin[1]]
 
        if (piece1.name == "King") && (piece1.has_moved == false)
            if (piece2 == "-")
                return false
            elsif (piece2.name == "Rook") && (piece2.has_moved == false)
                board_copy = []
                @board.each{|e| board_copy << e.dup}

                direction = (fin[1]-start[1] > 0)? 1 : -1
                temp = [start[0], start[1]+direction]
                #check if path between king and rook is empty
                while temp[1] != fin[1]
                    if @board[temp[0]][temp[1]] != "-"
                        return false
                    end
                    temp[1] += direction
                end 
                #check all positions (including start and final position) if king in check
                point = [start[0], start[1]] 
                while point[1].between?(0,7) 
                    if in_check?(piece1, @board)
                        @board = board_copy
                        return false
                    end
                    @board[point[0]][point[1]] = "-"
                    point[1] += direction 
                    if point[1].between?(0,7) then @board[point[0]][point[1]] = piece1 end
                end
                #Reset board
                @board = board_copy
                return true
            end
        end
        return false
    end

    def castle_move(start, fin)  
        piece1 = @board[start[0]][start[1]]
        piece2 = @board[fin[0]][fin[1]]
        piece1.has_moved = true
        piece2.has_moved = true
        #Make move
        if (fin[1]-start[1]) > 0 #rightside swap
            @board[start[0]][6] = piece1
            @board[start[0]][5] = piece2
        else #leftside swap
            @board[start[0]][2] = piece1
            @board[start[0]][3] = piece2
        end
        @board[start[0]][start[1]] = "-"
        @board[fin[0]][fin[1]] = "-"
    end

    def en_passant?(start, fin)
        forward = (@current_player == "p1")? -1 : 1

        if @last_move == [] then return false end

        last_start = @last_move[0]
        last_end = @last_move[1]
        piece = @board[last_end[0]][last_end[1]] #coordinates of the potential pawn to be captured
        
        if (@board[start[0]][start[1]].name == "Pawn") && (@board[fin[0]][fin[1]] == "-")
            if piece.name == "Pawn" || piece.player != @current_player
                #Enemy pawns must be directly next to one another
                if ((start[0]-last_end[0]) == 0) && ((start[1]-last_end[1]).abs == 1)
                    #pawn must've just done a double move
                    if (last_start[0]-last_end[0]).abs == 2
                        #Make sure selected finish square is directly BEHIND pawn to be captured
                        if ((fin[0]) == (last_end[0]+forward)) && (fin[1] == last_end[1])
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    def en_passant_move(start, fin)
        pawn = @board[start[0]][start[1]]
        last_end = @last_move[1]

        @board[fin[0]][fin[1]] = pawn
        @board[start[0]][start[1]] = "-"
        @board[last_end[0]][last_end[1]]= "-"
    end


    def promotion?(start, fin, current_piece)
        end_index = (current_piece.player == "p1")? 0 : 7
        #if reached opposite end of the board
        if fin[0] == end_index
            new_piece = promotion_menu(current_piece)
            @board[start[0]][start[1]] = new_piece
        end
    end

    def promotion_menu(current_piece)
        puts "\nWhat piece would you like?:\n"
        puts "Options:\n1.Queen\n2.Rook\n3.Bishop\n4.Knight\n"
        input = gets.chomp

        if input == "1"
            new_piece = Queen.new(current_piece.player)
        elsif input == "2"
            new_piece = Rook.new(current_piece.player)
        elsif input == "3"
            new_piece = Bishop.new(current_piece.player)
        elsif input == "4"
            new_piece = Knight.new(current_piece.player)
        end

        if new_piece then return new_piece else promotion_menu(current_piece) end
    end

    ############ SAVING GAME ################################3

    def save_game
        File.open("./data/Game.yml", "w"){|f|YAML.dump([] << self, f)}
    end

    def load_game
        begin
            yaml = YAML.load_file("./data/Game.yml")
            game = yaml[0].startRound()
        rescue
            puts "No game state found!"
        end
    end
end


game = Chess.new()
game.startMenu()