
%%MultiObjectiveOptimization
%   This function Calculates the Two-objective optimization of the input
%   case.
% author: fengfan
load input
input=OptInput;



options = nsgaopt();  

options.input=input;
% check the optimization variable
Variable = cell2mat(input.Design.Variable);
options.lb = [5.5,28.0,13.0,1,1,1,1];                 % lower bound of x
options.ub = [9.0,34.0,16.0,6,2,4,5];                  % upper bound of x
options.initpop=[ 5.5 30.0 16.0 2 1 2 5];

for ii=1:length(Variable(1,:))
    if Variable(1,ii)==0
        [options.lb(ii),options.ub(ii),options.initpop(ii)]=deal(Variable(2,ii));
    end
end
options.lb(1,1:3)=options.lb(1,1:3)*10;
options.ub(1,1:3)=options.ub(1,1:3)*10;
options.initpop(1,1:3)=options.initpop(1,1:3)*10;
options.numVar = 7;                     % number of design variables

                  % create default options structure
options.popsize = input.Population;                   % populaion size
options.maxGen  = input.Generation;                  % max generation

options.numObj = 2;                     % number of objectives

options.numCons = 1;                    % number of constraints

options.objfun = @MultiObjective;     % objective function handle
options.consfun=@NonlinearConstraints;
options.plotInterval = 1;               % interval between two calls of "plotnsga". 

options.vartype=[2,2,2,2,2,2,2];
options.useParallel='yes';
% options.poolsize=2;
options.poolsize=2;



options.crossover{1,1}='intermediate';
options.crossover{1,2}=0.8;
options.crossoverFraction=0.9;
options.mutation={'gaussian',0.5,0.75};
options.mutationFraction=4./options.numVar;

%options.crossover{1,1}='simulatedbinary';
%options.crossover{1,2}=20;% crossover operator distribution indices
%options.crossoverFraction=0.9;
%options.mutation={'polynominal',20};
%options.mutationFraction=1./options.numVar;

options.sortingfun={'nds',0.2};

options.surrogate.use=0;

surrogateOpt=getsurrogateOpt;

result = nsga2(options,surrogateOpt);                % begin the optimization!


