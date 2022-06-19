#Initializing
using DelimitedFiles
#Directory
cd("C:\\Users\\paulk\\Documents\\Programmieren\\Julia\\Utespiel") #home
#cd("C:\\Users\\StandardUser\\Documents\\Julia\\ute") #uni

#Color assignment
#colors = ((1,"gelb"),(2,"grau"),(3,"dunkelblau"),(4,"pink"),(5,"orange"),(6,"rot"),(7,"bordeaux"),(8,"cyan"),(9,"lila"),(10,"grün"),(11,"hellblau"),(12,"schwarz"))

#functions
function get_parameters(actualboard) # get needed parameters
    parameters = zeros(Int8,18,14) #18*14 matrix containing startindex, value, multiplicity and targetindex.
    #parameters matrix 18 x 14: Columns are startcolumns, 1st row is startindex, 2nd row is startvalue, 3rd row is multiplicity, 4th row for data and 5th-18th row are targetindices
    for startcolumn in 1:14
        if actualboard[4,startcolumn] != 0
            startindex = findfirst(!isequal(0),actualboard[:,startcolumn])
            startvalue = actualboard[findfirst(!isequal(0),actualboard[:,startcolumn]),startcolumn]
            if startindex == 1 #calculating multiplicity
                if actualboard[2,startcolumn] == startvalue && actualboard[3,startcolumn] == startvalue && actualboard[4,startcolumn] == startvalue
                    multiplicity = 3
                elseif actualboard[2,startcolumn] == startvalue && actualboard[3,startcolumn] == startvalue
                    multiplicity = 2
                elseif actualboard[2,startcolumn] == startvalue
                    multiplicity = 1
                else
                    multiplicity = 0
                end
            elseif startindex == 2
                if actualboard[3,startcolumn] == startvalue && actualboard[4,startcolumn] == startvalue
                    multiplicity = 2
                elseif actualboard[3,startcolumn] == startvalue 
                    multiplicity = 1
                else
                    multiplicity = 0
                end
            elseif startindex == 3
                if actualboard[4,startcolumn] == startvalue
                    multiplicity = 1
                else
                    multiplicity = 0
                end
            else
                multiplicity = 0
            end
            for targetcolumn in 1:14 
                targetindex = 0
                if actualboard[1,targetcolumn] == 0
                    if actualboard[2,targetcolumn] == 0
                        if actualboard[3,targetcolumn] == 0
                            if actualboard[4,targetcolumn] == 0
                                targetindex = 4
                            elseif actualboard[4,targetcolumn] == startvalue
                                targetindex = 3
                            end
                        elseif actualboard[3,targetcolumn] ==  startvalue
                            targetindex = 2
                        end
                    elseif actualboard[2,targetcolumn] == startvalue
                        targetindex = 1
                    end
                end
                parameters[targetcolumn+4,startcolumn] = targetindex
            end
            parameters[1,startcolumn] = startindex
            parameters[2,startcolumn] = startvalue
            parameters[3,startcolumn] = multiplicity
        end  
    end
    #show(stdout, "text/plain", parameters) #show parameters
    for dia in 1:14 #targetindex diagonal should be 0 (moves wont change the board)
        parameters[dia+4,dia] = 0
    end
    moves = count(>(0),parameters[5:18,:])
    parameters[4,1] = moves #save number of possible moves in first data space
    return parameters
end

function test_endcondition(parameters) #end final while loop, when end condition is met
    if length(findall(==(3),parameters[3,:])) == 12 #|| i == 1 #part with i is for testing
        global keep_going = false
        println("Job done")
    end       
end

function loopcheck(actual_boardpath) #check for equal boards (loops) (OLD)
    for i in 1:length(actual_boardpath[1,1,:])-1
        if actual_boardpath[:,:,i] == actual_boardpath[:,:,end]
            println("Loop detected: current board (nr ",length(actual_boardpath[1,1,:]),") is equal to nr ",i)
            #break #maybe make this a comment to see multiple loops
            global loopcounter += 1
            global loop = true
            if loop #do something when a loop is deteceted
                move_path[end] -= 1
                global counter += 1
                if loopcounter == 2
                    move_path[end] -= 1
                end
                global loopcounter = 0
                loop = false
                #when loop deteceted, jump back to the first similar board, and reduce path and moves accordingly ---- todo !!!!!!!!
            end
        end        
    end  
end  

function loopckeck_return(actual_board) #check for loop and jump back to the first unique setup (NEW)
    for i in 1:length(actual_board[1,1,:])-1
        if actual_board[:,:,i] == actual_board[:,:,end]
            #println("Loop detected: current board (nr ",length(actual_board[1,1,:]),") is equal to nr ",i)
            global parameter_path = parameter_path[:,:,1:i]
            global board_path = board_path[:,:,1:i]
            global move_path = move_path[1:i]
            global move_path[end] -= 1
        end        
    end  
end

function restart_parameters() #restart parameters for new final while loop
    global keep_going = true
    global i = 0
    global move_path = Int8[]
    global loop = false
    global counter = 0
    global loopcounter = 0
    return nothing
end

function getmoves(parameters) #out: moveparameters: startcolum, targetcolumn, startindex, startvalue, multiplicity, targetindex: possibmovesx6 matrix
    moves = findall(>(0),parameters[5:18,:])
    startcolumn, targetcolumn, startindex, startvalue, multiplicity, targetindex = Int8[], Int8[], Int8[], Int8[], Int8[], Int8[]
    for i in moves
        startcolumn = vcat(startcolumn,i[2])
        targetcolumn = vcat(targetcolumn,i[1])
        targetindex = vcat(targetindex,parameters[i[1]+4,i[2]])
    end
    for j in startcolumn
        startindex = vcat(startindex,parameters[1,j])
        startvalue = vcat(startvalue,parameters[2,j])
        multiplicity = vcat(multiplicity,parameters[3,j])
    end
    moveparameters = hcat(startcolumn,hcat(targetcolumn,hcat(startindex,hcat(startvalue,hcat(multiplicity,hcat(targetindex))))))
    return moveparameters
end

function domove(movepara,movenur)
    actualboard = board_path[:,:,end] #get actual board
    if movepara[movenur,5] == movepara[movenur,6]
        movepara[movenur,5] -= 1
    elseif movepara[movenur,5] == movepara[movenur,6]+1
        movepara[movenur,5] -= 2
    elseif movepara[movenur,5] == movepara[movenur,6]+2
        movepara[movenur,5] -= 3
    end
    actualboard[movepara[movenur,3]:movepara[movenur,3]+movepara[movenur,5],movepara[movenur,1]] .= 0 #write zeros to startingpoint
    actualboard[movepara[movenur,6]-movepara[movenur,5]:movepara[movenur,6],movepara[movenur,2]] .= movepara[movenur,4] #write values to targetpoint
    return actualboard
end

#write data to file
#open("parameters_test.txt","w") do io
#    writedlm(io,parameter_path)
#end

show(stdout, "text/plain", move_path)

#starting
#load board like in level 1267
board = readdlm("level_1267.txt",Int8)
restart_parameters()

while keep_going #actual running code
    if i == 0 #Initializing
        global board_path = board
        global parameter_path = get_parameters(board_path)
        global move_path = parameter_path[4,1]
    end
    #println(i)
    #println(move_path)
    if move_path[end] == 0 #no more moves
        move_path = move_path[1:end-1]
        move_path[end] -= 1
        parameter_path = parameter_path[:,:,1:end-1]
        board_path = board_path[:,:,1:end-1]
        #println("move_path is 0")
    else
        if getmoves(parameter_path[:,:,end])[move_path[end],3] + getmoves(parameter_path[:,:,end])[move_path[end],5] == 4 && 4 == getmoves(parameter_path[:,:,end])[move_path[end],6]
            move_path[end] -= 1
        else  
            #println("do magic")
            board_path = cat(board_path,domove(getmoves(parameter_path[:,:,end]),move_path[end]);dims=3)
            #println("domove")
            parameter_path = cat(parameter_path,get_parameters(board_path[:,:,end]);dims=3)
            #println("get_parameters")
            move_path = vcat(move_path,parameter_path[4,1,end])
            #println("move_path")
            if mod(i,1000) == 0
                println(move_path)
            end
            loopckeck_return(board_path)
        end
    end
    #sleep(0.1)
    test_endcondition(parameter_path[:,:,end]) #if true, keep_going -> false and the loop ends.
    global i += 1
end