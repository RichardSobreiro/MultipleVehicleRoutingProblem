int QuantityOfVehiclesAvailable = ...;
int QuantityOfClients = ...;
int VehicleCost = ...;

int VehiclesGreatestPossibleDemand = ...;

range Vehicles = 1..QuantityOfVehiclesAvailable;
range Locations = 1..(QuantityOfClients + 1);

float Time[Locations][Locations] = ...;
int VehiclesCapacity[Vehicles] = ...;
int GreatestPossibleDemand = ...;
float ClientsDemand[Locations] = ...;

int MPMN = QuantityOfClients + 1;

execute PARAMS {
  cplex.tilim = 10;
}

dvar boolean x[Locations][Locations][Vehicles];
dvar float p[Locations][Vehicles];
dvar float v[Locations][Vehicles];
dvar boolean vehicleIsUsed[Vehicles];

dvar float T;

minimize T + sum(k in Vehicles) (VehicleCost * vehicleIsUsed[k]);

subject to{
	
	FuncaoObjetivo:
	forall(k in Vehicles){
			T >= sum(j in Locations, i in Locations)(Time[i][j] * x[i][j][k]);
	}

	ChegadaImplicaEmSaidaDeUmCliente:
	forall(i in Locations,k in Vehicles){
		sum(j in Locations : i != j) x[j][i][k] == sum(j in Locations : i != j) x[i][j][k];	
	}	
		
	NoMaximoUmCaminhoChegaEmUmCliente:
	forall(j in Locations : j > 1){
		sum(k in Vehicles, i in Locations : i != j) x[i][j][k] <= 1;		
	}
	
	ApenasUmaRotaDeSaidaParaCadaCaminhao:
	forall(k in Vehicles){
		sum(j in Locations) x[1][j][k] <= 1;	
	}
		
	NoMaximoUmCaminhoSaiDeUmCliente:
	forall(i in Locations : i > 1) {
		sum(k in Vehicles, j in Locations : i != j) x[i][j][k] <= 1;	
	}
		
	EliminarSubTours:
	forall(k in Vehicles, j in Locations : j > 1) {
		forall(i in Locations : i > 1 && i != j) {
			MPMN * x[i][j][k] <= v[j][k] - v[i][k] - 1 + MPMN;
		}
	}
		
	SeVeiculoNaoVisitaClienteEntaoNaoRecolheNadaDoCliente:
	forall(k in Vehicles, j in Locations) {
		sum(i in Locations : i != j) GreatestPossibleDemand * x[i][j][k] >= p[j][k];	
	}
		
	ImplementaRestricaoLimiteDeCargaVeiculo:
	forall(k in Vehicles) {
		sum(i in Locations) p[i][k] <= VehiclesCapacity[k];				
	}
		
	ImplementaRestricaoTodosMateriasDoClienteDevemSerEntregues:
	forall(i in Locations) {
		sum(k in Vehicles) p[i][k] == ClientsDemand[i];		
	}
	
	VeiculoAtendeCliente:
	forall(k in Vehicles) {
		VehiclesGreatestPossibleDemand * vehicleIsUsed[k] >= sum(i in Locations) p[i][k];  		
	}
		
	VariaveisNaoNegativas:
	forall(k in Vehicles, i in Locations){
		p[i][k] >= 0;		
	}
}

/*execute {
	var f = new IloOplOutputFile("C:\\Users\\Richard\\Desktop\\Mulprod\\Solution1.txt");

	for(var k in Vehicles) {
		for(var j in Locations){
			//f.writeln("p[",j,"][",k,"] ",p[j][k]);
			for(var i in Locations){
				if(x[i][j][k] == 1){	
					f.writeln("x[",i,"][",j,"][",k,"]");			
				}	
			}			
		}
	}
	f.close();
}*/

execute {
	for(var k in Vehicles){
		for(var i in Locations) {
			if(x[i][j][k] == 1) {
				writeln("Ponto ",i," para o ponto ", j,". Entregou ", p[j][k]," no ponto ",j);			
			}	
		}			
	}

	for(var k in Vehicles) {
		writeln("Veiculo ",k,":");
		for(var j in Locations){
			for(var i in Locations) {
				if(x[i][j][k] == 1) {
					writeln("Ponto ",i," para o ponto ", j,". Entregou ", p[j][k]," no ponto ",j);			
				}	
			}			
		}
	}
}