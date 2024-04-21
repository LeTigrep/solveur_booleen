type eb = V of int | VRAI | FAUX | AND of eb * eb | OR of eb * eb | XOR of eb * eb | NAND of eb * eb
| NOT of eb ;;
 
 
(* fonction pour la concatenation *)
let rec concatenation (l1,l2) = match l1 with
[] -> l2 (* si la liste est vide, on concatene avec la deuxieme liste *)
| h :: t -> h :: concatenation (t,l2) (* la tete de l1 vas être concatener avec la queu de l1 ainsi que l2 *)
;;
 
(* fonction pour la liste de variable *)
let rec listevariable eb = match eb with
|V(x)->eb::[]
|VRAI->[]
|FAUX->[]
|AND(t,p)-> concatenation(listevariable t , listevariable p ) (*concatener chaque liste de variable*)
|OR(t,p) -> concatenation(listevariable t , listevariable p )
|XOR(t,p) -> concatenation(listevariable t , listevariable p )
|NAND(t,p) -> concatenation(listevariable t , listevariable p )
|NOT(t) -> listevariable t 
;;
 
 
(*fonction pour la fusion de listes *)
let rec fusion l1 l2 = match l1 with
[] -> []
| e :: li -> match l2 with
[] ->[]
| f :: l2 -> (e,f) :: fusion li l2;;
 
(*fonction pour générer des possibilités *)
let rec combi n a =
if n = 0 then [[]]
else
let res = combi (n-1) a in
List.concat (List.map (fun m -> List.map(fun s -> s@m) a) res);; (*pour chaque liste m dans res, elle concatène chaque élément s de a à m*)
 
 
(* fonction pour combiner les couples de listes *)
let rec combine_liste l_var elt = match elt with
[] -> []
| tete :: queu -> fusion l_var tete :: combine_liste l_var queu ;;
 
 
(*fonction pour chaque opérateur ici et or xor not et nand *)
let et v1 v2 = if v1 = VRAI then v2 else FAUX;;
let ou v1 v2 = if v1 = VRAI then VRAI else v2;;
let xor v1 v2 = if v1 != v2 then VRAI else FAUX;;
let not v1 = if v1 = VRAI then FAUX else VRAI;;
let nand v1 v2 = not(et v1 v2);;
 
(*fonction pour etudier l'appartenance d'un éléments à une liste*)

let rec appartient x l = match l with [] -> false | e :: li -> if x = e then true else appartient xli;;
 
(* fonction pour éliminer les doublons *)
let rec eliminer_doublons liste = match liste with
|[] -> []
|tete::queue ->
if appartient tete queue
then eliminer_doublons queue
else tete :: (eliminer_doublons queue);;
 
(*fonction pour la partie gauche de la liste (couple) *)
let rec partie_g e1 = match e1 with [] -> [] | e :: li -> fst(e) :: partie_g li;;
 
(*fonction pour la partie droite de la liste (couple) *)
let rec partie_d e1 = match e1 with [] -> [] | e :: li -> snd(e) :: partie_d li;;
 
(*fonction pour récuperer les variables *)
let rec variable l = match l with [] -> [] | e :: li -> listevariable e @ variable li;;
 
(* etape 1 de l'algorithme *)
let etape1 eb = List.sort compare (eliminer_doublons ((variable (partie_g eb) @ variable (partie_deb))));;

(* etape 2 de l'algorithme *)
let etape2 eb = let a = etape1 eb in combine_liste (a) ( combi (List.length a) ([[VRAI];[FAUX]]) );;

(* Renvoie la valeur associée de la variable dans un environnement donné en paramètre *)
let rec valeur_assoc v l = match l with [] -> raise (Not_found) | e :: l2 -> if fst(e) = v then snd(e) else valeur_assoc v l2;;

 
(*Applique un environnement sur une équation *)
let rec appliquer_env e env = match e with
FAUX -> FAUX
|V(i) -> valeur_assoc e env
|AND(x,y) -> et (appliquer_env x env) (appliquer_env y env)
|XOR(x,y) -> xor (appliquer_env x env) (appliquer_env y env)
|NAND(x,y)-> nand (appliquer_env x env) (appliquer_env y env)
|NOT x -> not (appliquer_env x env)
|VRAI -> VRAI 
|OR(x,y) -> ou (appliquer_env x env ) (appliquer_env y env);;
 
(*fonction pour voir si les listes sont identiques, si c'est le cas, c'est une solution *)
let rec equals l1 l2 = match l1 with [] -> if l2 = [] then true else false
| e :: li -> if e != List.hd (l2) then false else equals (li)
(List.tl (l2));;
 
(*Applique un environnement sur une la partie gauche ou partie droite du systeme d'équation *)
let rec appliquer_sys sys env = match sys with [] -> [] | e :: li -> (appliquer_env e env )::
appliquer_sys li env;;
 
(* fonction pour resoudre le systeme pour l'étape 3 *)
let rec applique sys envl = match sys with
[] -> []
| e :: li -> match envl with [] -> []
|f :: l2 -> let g = appliquer_sys (partie_g sys) (f) in let

d = appliquer_sys (partie_d sys) (f) in
if equals g d == true then f :: applique sys l2
else applique sys l2;;
