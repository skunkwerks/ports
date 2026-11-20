#[rustler::nif]
fn greet(name: String) -> String {
    format!("hello, {}!", name)
}

rustler::init!("Elixir.RustGreet", [greet]);
