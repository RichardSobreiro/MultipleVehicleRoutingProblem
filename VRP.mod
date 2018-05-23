int QuantityOfClients = ...;
range Locations = 1..(QuantityOfClients + 1);

float Distance[Locations][Locations] = ...;
float ClientsDemand[Locations] = ...;
int MPMN = QuantityOfClients + 1;

dvar boolean x[Locations][Locations];
dvar int v[Locations];

minimize sum(i in Locations, j in Locations) x[i][j] * Distance[i][j];

subject to{
	UmEApenasUmCaminhoDeveSairDeTodoLocal:
	forall(i in Locations) {
		sum(j in Locations: i != j) x[i][j] == 1;
	}
	
	UmEApenasUmCaminhoDeveChegarEmTodoLocal:
	forall(j in Locations: j > 1){
		sum(i in Locations: i != j) x[i][j] == 1;	
	}
	
	v[1] == 1;
	
	v[QuantityOfClients + 1] == QuantityOfClients + 1;
	
	EliminarSubTours:
	forall(j in Locations) {
		forall(i in Locations: i != j) {
			MPMN * x[i][j] <= v[j] - v[i] - 1 + MPMN;			
		}	
	}
}

/*execute {
	var f = new IloOplOutputFile("C:\\Users\\Richard\\Desktop\\Mulprod\\SolutionVRP.txt");

	for(var i in Locations) {
		f.writeln(v[i]);		
	}
		
	f.close();
}*/

execute {
	for(var i in Locations) {
		writeln("Ponto ",i,": ",v[i]);		
	}

	for(var i in Locations) {
		for(var j in Locations) {
			if(x[i][j] == 1) {
				writeln("Ponto ",i," para o ponto ", j);			
			}	
		}			
	}
}