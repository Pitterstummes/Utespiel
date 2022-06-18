#Initializing
using DelimitedFiles

#Directory
cd("C:\\Users\\paulk\\Documents\\Programmieren\\Julia\\Utespiel") #home
#cd("C:\\Users\\StandardUser\\Documents\\Julia\\ute") #uni

#Color assignment
#colors = ((1,"gelb"),(2,"grau"),(3,"dunkelblau"),(4,"pink"),(5,"orange"),(6,"rot"),(7,"bordeaux"),(8,"cyan"),(9,"lila"),(10,"grün"),(11,"hellblau"),(12,"schwarz"))

#load board like in level 1267
board = readdlm("level_1267.txt",Int8)

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
    if length(findall(==(3),parameters[3,:])) == 12 || i == 12 #part with i is for testing
        global keep_going = false
        println("Job done")
    end       
end

function loopcheck(actual_boardpath) #check for equal boards (loops)
    for i in length(actual_boardpath[1,1,:])-1
        if actual_boardpath[:,:,i] == actual_boardpath[:,:,end]
            println("Loop detected: current board (nr ",length(actual_boardpath[1,1,:]),") is equal to nr ",i)
            break #maybe make this a comment to see multiple loops
        end        
    end  
end  

function restart_parameters() #restart parameters for new final while loop
    global keep_going = true
    global i = 0
    global move_path = Int8[]
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


#Comments
#delete the last element of an vector
#deleteat!(vector,length(vector))

#for multidimensional
#a = zeros(3,3,3)
#a = a[:,:,1:end-1]

#write data to file
#open("parameters_test.txt","w") do io
#    writedlm(io,parameter_path)
#end


#starting

restart_parameters()

while keep_going #actual running code
    if i == 0
        global board_path = board
        global parameter_path = get_parameters(board_path)
        global move_path = parameter_path[4,1,end]
    else
        global parameter_path = cat(parameter_path,get_parameters(board_path[:,:,end]);dims=3)
        global move_path = hcat(move_path,parameter_path[4,1,end])
        #global board_path = cat(board_path,move(???);dims=3)
    end
    println(i)
    test_endcondition(parameter_path[:,:,end]) #if true, keep_going -> false and the loop ends.
    global i += 1
end