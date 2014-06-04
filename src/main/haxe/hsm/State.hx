package hsm;

@doc("Hoare logic primitive.")
enum State<T>{
  Enter;
  Leave;
  Update(v:T);
}
