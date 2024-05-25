open Core
open Core_unix

let convert_to_char morse = 
  match morse with
  | ".-" -> "A"
  | "-..." -> "B"
  | "-.-." -> "C"
  | "-.." -> "D"
  | "." -> "E"
  | "..-." -> "F"
  | "--." -> "G"
  | "...." -> "H"
  | ".." -> "I"
  | ".---" -> "J"
  | "-.-" -> "K"
  | ".-.." -> "L"
  | "--" -> "M"
  | "-." -> "N"
  | "---" -> "O"
  | ".--." -> "P"
  | "--.-" -> "Q"
  | ".-." -> "R"
  | "..." -> "S"
  | "-" -> "T"
  | "..-" -> "U"
  | "...-" -> "V"
  | ".--" -> "W"
  | "-..-" -> "X"
  | "-.--" -> "Y"
  | "--.." -> "Z"
  | "/" -> " "
  | _ -> "?"

let rec translate morse_list = 
  match morse_list with
  | [] -> ""
  | (x::xs) -> (convert_to_char x) ^ translate xs

let filter_silencedetect_lines input_file output_file =
  let ic = In_channel.create input_file in
  let oc = Out_channel.create output_file in
  Out_channel.output_string oc "silence_end: 0.0 | silence_duration: 0.0\n";
  let rec filter_lines () =
      let line = In_channel.input_line ic in
      match line with 
        | Some str -> if String.length str > 14 && String.is_prefix str ~prefix:"[silencedetect" then Out_channel.output_string oc (str ^ "\n"); filter_lines ()
        | None -> ()
  in
  filter_lines ();
  In_channel.close ic;
  Out_channel.close oc

let extract_first_float line =
  let split = String.split_on_chars line ~on:[':';'|'] in
  match split with
  | [_;y] -> float_of_string (String.lstrip y)
  | (_::x1::_) -> float_of_string (String.strip x1) 
  | _ -> -1.0

let to_tuples input_file = 
  let ic = In_channel.create input_file in
  let rec read_lines acc = 
    let silence_end = In_channel.input_line ic in
    let silence_start = In_channel.input_line ic in
    match silence_start with 
    | Some start_ -> 
      (match silence_end with 
        | Some end_ -> let end_num = extract_first_float end_ in
                       let start_num = extract_first_float start_ in
                       read_lines ((start_num,end_num)::acc)
        | None -> acc 
      )
    | None -> acc
    in read_lines []


let handle_tups tups = 
  let rec create_string acc l last_time = 
    match l with 
    | [] -> acc
    | (x::xs) -> 
      let l_time = match x with | (a,_) -> a in 
        if Float.(last_time - l_time < 0.8) then 
        let newacc = 
        (match x with
        | (a,b) -> if Float.(a - b < 0.1) 
          then acc ^ "." 
          else acc ^ "-") 
        in create_string newacc xs l_time
      else if Float.(last_time - l_time < 1.5) then
        let newacc = 
          (match x with
          | (a,b) -> if Float.(a - b < 0.1) 
            then acc ^ " ." 
            else acc ^ " -") 
          in create_string newacc xs l_time
        else
          let newacc = 
            (match x with
            | (a,b) -> if Float.(a - b < 0.1) 
              then acc ^ " / ." 
              else acc ^ " / -") 
            in create_string newacc xs l_time
    in 
    create_string "" tups 0.0

(* let rec print_tups tups =
  match tups with 
  | [] -> ()
  | (x::xs) -> (match x with | (a,b) -> printf "(%f, %f)\n" a b); print_tups xs
*)

let run_command cmd =
  let proc_channels =
    open_process_full cmd ~env:(Core_unix.environment ()) in
  close_process_full proc_channels

let () = 
  (* Change filepath to audio here *)
  let _ = run_command "ffmpeg -i input/longer_test.wav -af \"silencedetect=noise=-30dB:d=0.01\" -f null - 2> input/silencedetect_output.txt" in
  
  filter_silencedetect_lines "input/silencedetect_output.txt" "input/filtered_output.txt";
  let tups = to_tuples "input/filtered_output.txt" in
  (*print_tups tups;*)
  let morse = String.rev (handle_tups tups) in 
  let translation = translate (String.split morse ~on:' ') in
  print_endline morse;
  print_endline translation

(* ffmpeg -i hello_world.wav -af "silencedetect=noise=-30dB:d=0.01" -f null - 2> silencedetect_output.txt *)
(* https://www.meridianoutpost.com/resources/etools/calculators/calculator-morse-code.php? *)
(* 7 WPM, 1000 Hz *)