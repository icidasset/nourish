module List.Ext exposing (..)


isSubsequenceOf : List a -> List a -> Bool
isSubsequenceOf subseq list =
    case ( subseq, list ) of
        ( [], _ ) ->
            True

        ( _, [] ) ->
            False

        ( x :: xs, y :: ys ) ->
            if x == y then
                isSubsequenceOf xs ys

            else
                isSubsequenceOf subseq ys
