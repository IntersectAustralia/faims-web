grammar Statement;

program returns [String value]
    : s=statement { $value = $s.value; }
    ;

statement returns [String value]
    : 'if' e=multi_expression 'then' v=literal s=next_statement? 
        { 
            if ($e.value == true)
                $value = $v.value;
            else if ($s.value != null)
                $value = $s.value;
            else
                $value = "";
        }
    ;

next_statement returns [String value]
    : 'elsif' e=multi_expression 'then' v=literal s=next_statement?
        { 
            if ($e.value == true)
                $value = $v.value;
            else if ($s.value != null)
                $value = $s.value;
            else
                $value = "";
        }
    | 'else' v=literal
        { 
            $value = $v.value;
        }
    ;

multi_expression returns [Boolean value]
    : 'and(' l=single_expression ',' r=multi_expression ')' { $value = $l.value && $r.value; }
    | 'or(' l=single_expression ',' r=multi_expression ')' { $value = $l.value || $r.value; }
    | e=single_expression { $value = $e.value; }
    ;

single_expression returns [Boolean value]
    : 'equal(' l=literal ',' r=literal ')'
        {
            $value = ($l.value == null && $r.value == null) || $l.value.equals($r.value);
        }
    | 'greaterThan(' l=literal ',' r=literal ')'
        {
            $value = $l.value != null && $r.value != null && Float.parseFloat($l.value) > Float.parseFloat($r.value);
        }
    | 'greaterThanEqual('l=literal ',' r=literal ')'
        {
            $value = $l.value != null && $r.value != null && Float.parseFloat($l.value) >= Float.parseFloat($r.value);
        }
    | 'lessThan(' l=literal ',' r=literal ')'
        {
            $value = $l.value != null && $r.value != null && Float.parseFloat($l.value) < Float.parseFloat($r.value);
        }
    | 'lessThanEqual(' l=literal ',' r=literal ')'
        {
            $value = $l.value != null && $r.value != null && Float.parseFloat($l.value) <= Float.parseFloat($r.value);
        }
    | 'between(' l=literal ',' min=literal ',' max=literal ')'
        {
            $value = $l.value != null && $min.value != null && $max.value != null && Float.parseFloat($l.value) >= Float.parseFloat($min.value) && Float.parseFloat($l.value) <= Float.parseFloat($max.value);
        }
    | 'not(' e=single_expression ')' 
        { 
            if ($e.value == true)
                $value = false;
            else
                $value = true;
        }
    | 'in(' l=literal ',' items=list ')' { $value = $items.value.indexOf($l.value) >= 0; }
    | l=literal { $value = $l.value != null; }
    ;

list returns [java.util.ArrayList value]
    : '[' l=literals ']' { $value = $l.value; }
    ;

literals returns [java.util.ArrayList value]
    : l=literal ',' rest=literals
        {
            $value = $rest.value;
            $value.add($l.value);
        }
    | l=literal
        {
            $value = new java.util.ArrayList();
            $value.add($l.value);
        }
    ;

literal returns [String value]
    : s=STRING
        {
            if ($s.text != null) {
                $value = $s.text.substring(1,$s.text.length()-1);
            }
        }
    | v=VARIABLE
        {
            if ($v.text != null) {
                $value = ArgumentMap.getValue($v.text);
            }
        }
    | n=NUMBER
        {
            if ($n.text != null) {
                $value = $n.text;
            }
        }
    | i=INT
        {
            if ($i.text != null) {
                $value = $i.text;
            }
        }
    ;

NEWLINE     : '\n' -> skip ;
SPACE       : ' '+ -> skip ;
STRING      : '\'' ~('\'')* '\''
            | '\"' ~('\"')* '\"'
            ;
NUMBER      : '-'? DIGIT+ '.' DIGIT+ ;
INT         : '-'? DIGIT+ ;
VARIABLE    : '$' DIGIT+ ;

fragment DIGIT : ('0' .. '9') ;