defmodule Poker do
    
    def deal ([a, b, c, d | table]) do
        hand1 = [a, c] |> toCard()
        hand2 = [b, d] |> toCard()
        table = table |> toCard()
       
        IO.puts "-------------"
        IO.inspect table
        IO.inspect hand1
        IO.inspect hand2
        IO.puts "-------------"

        cond do
            royalFlush(hand1, table) != nil or royalFlush(hand2, table) != nil -> IO.inspect bestHand(royalFlush(hand1, table), royalFlush(hand2, table))
            straightFlush(hand1, table) != nil or straightFlush(hand2, table) != nil -> IO.inspect bestHand(straightFlush(hand1, table), straightFlush(hand2, table))
            fourOfAKind(hand1, table) != nil or fourOfAKind(hand2, table) != nil -> IO.inspect bestHand(fourOfAKind(hand1, table), fourOfAKind(hand2, table))
            fullHouse(hand1, table) != nil or fullHouse(hand2, table) != nil -> IO.inspect bestHand(threeOfAKind(hand1, table), threeOfAKind(hand2, table)) #threeOfAKindInstead of fullhouse
            flush(hand1, table) != nil or flush(hand2, table) != nil -> IO.inspect bestHand(flush(hand1, table), flush(hand2, table))
            straight(hand1, table) != nil or straight(hand2, table) != nil -> IO.inspect bestHand(straight(hand1, table), straight(hand2, table))
            threeOfAKind(hand1, table) != nil or threeOfAKind(hand2, table) != nil -> IO.inspect bestHand(threeOfAKind(hand1, table), threeOfAKind(hand2, table))
            twoPair(hand1, table) != nil or twoPair(hand2, table) != nil -> IO.inspect bestHand(twoPair(hand1, table), twoPair(hand2, table))
            pair(hand1, table) != nil or pair(hand2, table) != nil -> IO.inspect bestHand(pair(hand1, table), pair(hand2, table))
            highCard(hand1) != nil or highCard(hand2) != nil -> IO.inspect bestHand(highCard(hand1), highCard(hand2))
            true -> nil
        end

    end

    def bestHand(hand1, hand2) do
        cond do 
            hand1 == nil -> hand2
            hand2 == nil -> hand1
            true-> highestHand(hand1, hand2)
        end
    end
    
    def toCard (list) do
        list
        |> Enum.map(fn n -> {if(rem(n, 13) == 0, do: 13, else: rem(n, 13)), numToSuit(n)} end) 
        |> Enum.to_list()
    end

    def numToSuit(num) do
        cond do
            num >= 40 -> 'S'
            num >= 27 -> 'H'
            num >= 14 -> 'D'
            true -> 'C'
        end
    end

    def highCard(list) do 
        list = list |> Enum.sort()
        #Check for ace
        if elem(list |> List.first(), 0) == 1 do
            #Largest Suit in all aces
            list |> Enum.filter(fn x -> elem(x, 0) == 1 end)|> List.last()
        else
            #Largest Val and Suit
            list |> List.last()
        end
    end

    def highestHand(list1, list2) do
        card1 = highCard(list1)
        card2 = highCard(list2)
        highestCard = highCard([card1, card2])
        
        cond do
            list1 |> Enum.member?(highestCard) -> list1
            list2 |> Enum.member?(highestCard) -> list2
            true -> nil
        end
    end

    def highCardInFreq(list) do 
        list = list |> Enum.sort()
        if elem(list |> List.first(), 0) == 1 do
            #Ace largest in freq
            list |> List.first()
        else
            #Largest in freq not ace
            list |> List.last()
        end
    end


    def pair([card1, card2], table) do
        count = [card1, card2] ++ table |> Enum.sort_by(&elem(&1, 1))
        vals = count |> Enum.unzip() |> elem(0)
        freq = Enum.frequencies(vals) |> Enum.filter(fn x -> elem(x, 1) == 2 end)
        freqInHand = Enum.filter(freq, fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == if(rem(elem(y, 0), 13) == 0, do: 13, else: rem(elem(y, 0), 13))end)end)
    
        if (length(freq) == 0) do
            nil
        else
            count
            |> Enum.filter(fn x -> elem(x, 0) == elem(freqInHand |> highCardInFreq(), 0) end)
            |> Enum.sort()
        end
    end

    def twoPair([card1, card2], table) do
        count = [card1, card2] ++ table |> Enum.sort_by(&elem(&1, 1))
        vals = count |> Enum.unzip() |> elem(0)
        freq = Enum.frequencies(vals) |> Enum.filter(fn x -> elem(x, 1) == 2 end) |> Enum.sort()
        freqInHand = Enum.filter(freq, fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == if(rem(elem(y, 0), 13) == 0, do: 13, else: rem(elem(y, 0), 13))end)end)

        if (length(freqInHand) <= 1) do
            nil
        else

            #only 2 pairs avaliable
            if length(freq) == 2 do
                count
                |> Enum.filter(fn x -> Enum.any?(freq, fn {h,2} -> elem(x, 0) == h end) end)
                |> Enum.sort()
            
            #More than 2 pairs avaliable
            else
                allPairs = count
                |> Enum.filter(fn x -> Enum.any?(freq, fn {h,2} -> elem(x, 0) == h end) end)
                |> Enum.sort() 
            
                highestPairInHand = count
                |> Enum.filter(fn x -> Enum.any?([freqInHand |> highCardInFreq()], fn {h,2} -> elem(x, 0) == h end) end)
                |> Enum.sort() 

                allPairs = allPairs -- highestPairInHand
            
                #Second Highest pair
                highestPair2 = allPairs |> highCard() |> elem(0)
                (allPairs |> Enum.filter(fn x -> elem(x, 0) == highestPair2 end)) ++ highestPairInHand
                |> Enum.sort()
            end
        end
    end

    def threeOfAKind([card1, card2], table) do
        freqInHand = [card1, card2] ++ table 
        |> Enum.unzip() 
        |> elem(0)
        |> Enum.frequencies() 
        |> Enum.filter(fn x -> elem(x, 1) == 3 end) 
        |> Enum.sort()
        |> Enum.filter(fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == if(rem(elem(y, 0), 13) == 0, do: 13, else: rem(elem(y, 0), 13))end)end)
        
        if length(freqInHand) == 0 do
            nil
        else
            cond do
                freqInHand == nil -> nil
                freqInHand |> List.first() |> elem(0) == 1 -> [card1, card2] ++ table |> Enum.filter(fn x-> rem(elem(x,0), 13) == 1 end) 
                true -> [card1, card2] ++ table |> Enum.filter(fn x-> rem(elem(x,0), 13) == rem(elem(freqInHand |> List.last(), 0), 13) end) 
            end
        end
    end

    def fourOfAKind([card1, card2], table) do
        freqInHand = [card1, card2] ++ table 
        |> Enum.unzip() 
        |> elem(0)
        |> Enum.frequencies() 
        |> Enum.filter(fn x -> elem(x, 1) == 4 end) 
        |> Enum.sort()
        |> Enum.filter(fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == if(rem(elem(y, 0), 13) == 0, do: 13, else: rem(elem(y, 0), 13))end)end)
        
        if length(freqInHand) == 0 do
            nil
        else
            cond do
                freqInHand == nil -> nil
                true -> [card1, card2] ++ table |> Enum.filter(fn x-> rem(elem(x,0), 13) == rem(elem(freqInHand |> List.last(), 0), 13) end) 
            end
        end
    end

    def straight([card1, card2], table) do
        cards = [card1, card2] ++ table |> Enum.sort()
        list = [card1, card2] ++ table 
        |> Enum.unzip()
        |> elem(0)
        |> Enum.uniq()
        |> Enum.sort()
        
        if length(list) < 5 do
            nil
        else
            #10, j , q , k , A
            if MapSet.subset?(MapSet.new([1, 10, 11, 12, 13]), MapSet.new(list)) == true do
                [1, 10, 11, 12, 13] 
                |> Enum.map(fn x -> Enum.filter(cards, fn y -> elem(y,0) == x end) |> List.last() end)
            else
                lastIndex = list 
                |> Enum.reverse()
                |> Enum.find(fn x -> Enum.find_index(list, fn y-> y == x end) - 4 == Enum.find_index(list, fn y-> y == x - 4 end) end)
                if lastIndex == nil do
                    nil
                else
                    lastIndex-4..lastIndex |> Enum.to_list() |> Enum.map(fn x -> Enum.filter(cards, fn y -> elem(y,0) == x end) |> List.last() end)
                end
            end
        end
    end

    #not enoguht cards error
    def flush([card1, card2], table) do
        flushSuit = [card1, card2] ++ table 
        |> Enum.frequencies_by(fn x-> elem(x,1) end)
        |> Enum.filter(fn x -> elem(x, 1) >= 5 end)
        |> Enum.filter(fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == elem(y, 1) end)end)
        |> List.last()
        
        if flushSuit == nil do 
            nil
        else
            flushSuit = flushSuit |> elem(0) 
            cardsSameSuit = [card1, card2] ++ table
            |> Enum.filter(fn {_, x} -> x == flushSuit end)
            |> Enum.sort()
            
            cond do
                flushSuit == nil -> nil
                cardsSameSuit |> List.first() |> elem(0) == 1 -> (cardsSameSuit |> Enum.reverse() |> Enum.take(4)) ++ [cardsSameSuit |> List.first()] |> Enum.sort()
                true -> cardsSameSuit |> Enum.reverse() |> Enum.take(5)
            end
        end
    end

    def fullHouse([card1, card2], table) do
        #triple
        triple = threeOfAKind([card1, card2], table)
        
        if triple == nil do
            nil
        else
            #pair
            cardsRemaining = [card1, card2] ++ table -- triple
            freq = cardsRemaining 
            |> Enum.unzip() 
            |> elem(0)
            |> Enum.frequencies() 
            |> Enum.filter(fn x -> elem(x, 1) >= 2 end)
            |> Enum.sort()

            if freq |> List.first() |> elem(0) == 1 do
                pair = cardsRemaining 
                |> Enum.filter(fn x -> x |> elem(0) == 1 end) 
                |> Enum.sort() 
                |> Enum.reverse() 
                |> Enum.slice(0..1)
                triple ++ pair
            else
                pair = cardsRemaining 
                |> Enum.filter(fn x -> x |> elem(0) == freq |> List.last() |> elem(0) end) 
                |> Enum.sort() 
                |> Enum.reverse() 
                |> Enum.slice(0..1) 
                triple ++ pair
            
            end 
        end
    end

    #not enoguht cards error
    def straightFlush([card1, card2], table) do
        flushSuit = [card1, card2] ++ table 
        |> Enum.frequencies_by(fn x-> elem(x,1) end)
        |> Enum.filter(fn x -> elem(x, 1) >= 5 end)
        |> Enum.filter(fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == elem(y, 1) end)end)
        |> List.last()
        
        if flushSuit == nil do 
            nil
        else
            flushSuit = flushSuit |> elem(0)
            cardsSameSuit = [card1, card2] ++ table
            |> Enum.filter(fn {_, x} -> x == flushSuit end)
            |> Enum.sort()


            cards = cardsSameSuit |> Enum.sort()
            list = cardsSameSuit 
            |> Enum.unzip()
            |> elem(0)
            |> Enum.uniq()
            |> Enum.sort()

            if length(list) < 5 do
                nil
            else
                lastIndex = list 
                |> Enum.reverse()
                |> Enum.find(fn x -> Enum.find_index(list, fn y-> y == x end) - 4 == Enum.find_index(list, fn y-> y == x - 4 end) end)

                lastIndex-4..lastIndex |> Enum.to_list() |> Enum.map(fn x -> Enum.filter(cards, fn y -> elem(y,0) == x end) |> List.last() end)

            end
        end
    end

    def royalFlush([card1, card2], table) do
        flushSuit = [card1, card2] ++ table 
        |> Enum.frequencies_by(fn x-> elem(x,1) end)
        |> Enum.filter(fn x -> elem(x, 1) >= 5 end)
        |> Enum.filter(fn x -> Enum.any?([card1, card2], fn y -> elem(x, 0) == elem(y, 1) end)end)
        |> List.last()

        if flushSuit == nil do 
            nil
        else
            flushSuit = flushSuit |> elem(0) 
            cardsSameSuit = [card1, card2] ++ table
            |> Enum.filter(fn {_, x} -> x == flushSuit end)
            |> Enum.sort()

            cards = cardsSameSuit |> Enum.sort()
            list = cardsSameSuit 
            |> Enum.unzip()
            |> elem(0)
            |> Enum.uniq()
            |> Enum.sort()

            if length(list) < 5 do
                nil
            else
                if MapSet.subset?(MapSet.new([1, 10, 11, 12, 13]), MapSet.new(list)) == true do
                    [1, 10, 11, 12, 13] 
                    |> Enum.map(fn x -> Enum.filter(cards, fn y -> elem(y,0) == x end) |> List.last() end)
                else
                    nil
                end
            end
        end
    end
end


Poker.deal([2, 7, 13, 12, 2, 3, 4, 5, 6])