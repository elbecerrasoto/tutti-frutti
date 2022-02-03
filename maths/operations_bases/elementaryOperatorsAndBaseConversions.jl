#!/usr/bin/julia

function base10ToAny(in_dig,base)
    if base >= 21
        println("Warning: There're not special characters for digits in base 21 or more")
    end
    digits_b10=[]
    q=in_dig
    while true
        if q % base <= 9
            push!(digits_b10,q % base)
        elseif q % base == 10
            push!(digits_b10,'A')
        elseif q % base == 11
            push!(digits_b10,'B')
        elseif q % base == 12
            push!(digits_b10,'C')
        elseif q % base == 13
            push!(digits_b10,'D')
        elseif q % base == 14
            push!(digits_b10,'E')
        elseif q % base == 15
            push!(digits_b10,'F')
        elseif q % base == 16
            push!(digits_b10,'G')
        elseif q % base == 17
            push!(digits_b10,'H')
        elseif q % base == 18
            push!(digits_b10,'I')
        elseif q % base == 19
            push!(digits_b10,'J')
        else
            r=(q % base)
            push!(digits_b10,"($r)")
        end
        q=div(q,base)
        if q == 0
            break
        end
    end
    l=length(digits_b10)
    for idx in 1:l
        print(pop!(digits_b10))
    end
end

function anyBaseTo10(iterDig,base)
    if base >= 21
        println("Error: Only works for a base 20 or less")
        return
    end
    if !isa(iterDig,AbstractString)
        println("Error: Input n should be a string")
        return
    end
    summation=0
    l=sizeof(iterDig)
    for idx in 1:l
        digit = iterDig[ l - (idx-1)]
        if digit == 'A'
            digit = 10
        elseif digit == 'B'
            digit = 11
        elseif digit == 'C'
            digit = 12
        elseif digit == 'D'
            digit = 13
        elseif digit == 'E'
            digit = 14
        elseif digit == 'F'
            digit = 15
        elseif digit == 'G'
            digit = 16
        elseif digit == 'H'
            digit = 17
        elseif digit == 'I'
            digit = 18
        elseif digit == 'J'
            digit = 19
        else
            digit = parse(Int64, digit)
        end
        summation = digit*(base^(idx-1)) + summation
    end
    println(summation)
end

function binAddition(in_bin_1,in_bin_2)
    ib1=string(in_bin_1)
    ib2=string(in_bin_2)
    l1=sizeof(ib1)
    l2=sizeof(ib2)
    if l1 > l2
        AddZeros = l1 - l2
        ib2=("0" ^ AddZeros) * ib2
        larger=l1
    elseif l2 > l1
        AddZeros = l2 - l1
        ib1=("0" ^ AddZeros) * ib1
        larger=l2
    else
        larger=l1
    end
    c=0
    all_s=[]
    for idx in 1:larger
        dig1= parse(Int64, ib1[ larger - (idx-1) ])
        dig2= parse(Int64, ib2[ larger - (idx-1) ])
        d=div( dig1 + dig2 + c, 2)
        s=dig1 + dig2 + c - 2d
        c=d
        push!(all_s,s)
    end
    push!(all_s,c)
    justZero = true
    #println("all_s is:", all_s)
    for idx in 1:length(all_s)
        if length(all_s) == 2 && join(all_s) == "00"
            print(all_s[ length(all_s) - (idx -1 ) ])
            break
        end
        if justZero && all_s[ length(all_s) - (idx -1 ) ] == 0
            continue
        end
        if all_s[ length(all_s) - (idx -1 ) ]  == 1
            justZero = false
        end
        print(all_s[ length(all_s) - (idx -1 ) ])
    end
end

function binMultiplication(a,b)
end

#21 * 21
#441
#110111001

a=10101
b=10101
a=string(a)
b=string(b)
la=sizeof(a)
lb=sizeof(b)
if la > lb
    AddZeros = la - lb
    b=("0" ^ AddZeros) * b
    larger=la
elseif lb > la
    AddZeros = lb - la
    a=("0" ^ AddZeros) * a
    larger=lb
else
    larger=la
end
c_partials=[]
for idx in 1:larger
    #println("b[larger - (idx -1)] is\t", b[larger - (idx -1)])
    if b[larger - (idx -1)] == '1'
        c = a * ("0" ^ (idx - 1))
        #println("This is a: \t",a)
        push!(c_partials,c)
    else
        c = "0"
        push!(c_partials,c)
    end
end
p = 0
#println("This is c_partials: \t",c_partials)
for partial in c_partials
    println("Partial is $partial")
    partial = parse(Int64, partial)

    println("Value of function is: ", binAddition(p,partial) )
    p = binAddition(p,partial)
end
