function InputInfo=ReadInputFile(FileName)
% This function helps check the Input information. Warn if there is any
% mistakes.
status=xlsfinfo(FileName);
if isempty(status)
    error ('Cannot read InputFile.xlsx. Maybe they are not 7-bit ASCII characters.')
end

[~,~,Input]=xlsread(FileName);

%% Simulation Control
InputInfo.SimulationControl.StartDate=[Input{494,3},Input{494,4},Input{494,5}];
InputInfo.SimulationControl.EndDate=[Input{495,3},Input{495,4},Input{495,5}];

BaseTimeNum=datenum([InputInfo.SimulationControl.StartDate(1,1),01,01]);
StartDateNum=datenum(InputInfo.SimulationControl.StartDate);
EndDateNum=datenum(InputInfo.SimulationControl.EndDate);

TimeStep=24*(EndDateNum-StartDateNum);
if TimeStep==0
   error('Please select different starting date and ending date!') 
end

%% Check building information
InputInfo.BuildingInfo.FloorNumber=Input{2,3};
InputInfo.BuildingInfo.FloorHeight=Input{3,3};
if (InputInfo.BuildingInfo.FloorHeight<=2.5||InputInfo.BuildingInfo.FloorHeight>=10)
    warning ('FloorHeight maybe unreasonable!');
end

InputInfo.BuildingInfo.ZoneNum=Input{4,3};
if InputInfo.BuildingInfo.ZoneNum<=0||InputInfo.BuildingInfo.ZoneNum>6
    warning ('The Range of Vertical Zone Number should be [0,6].');
end

InputInfo.BuildingInfo.EnergyStation=Input{5,3};
if (InputInfo.BuildingInfo.EnergyStation<=0||InputInfo.BuildingInfo.EnergyStation>=3)
    warning ('The Range of Energy Station Number should be [0,2].');
end

% check the representive floor
InputInfo.BuildingInfo.RepFloorNum=Input{6,3};

% check the number of validated path of load file.
Path1=Input{8,3};
Path2=Input{10,3};
Path3=Input{12,3};
Path4=Input{14,3};

Number=[isstr(Path1),isstr(Path2),isstr(Path3),isstr(Path4)];

if sum(Number)~=InputInfo.BuildingInfo.RepFloorNum
    error('The number of Load File doesnot match the number of Representive Floor!')
end
% check the floor number of each representive floor
% if Input{7,3}~=1
%     error ('Floor 1 should have been considered!');
% elseif (Input{9,3}~=Input{7,4}+1)||(Input{11,3}~=Input{9,4}+1)||(Input{13,3}~=Input{11,4}+1)
%     error ('Floor range should be consecutive number!')
% elseif Input{13,4}~=InputInfo.BuildingInfo.FloorNumber
%     error ('The representive floor range should match the Floor Number!')
% end

InputInfo.BuildingInfo.Load.R1.LoadPath=Path1;
InputInfo.BuildingInfo.Load.R2.LoadPath=Path2;
InputInfo.BuildingInfo.Load.R3.LoadPath=Path3;
InputInfo.BuildingInfo.Load.R4.LoadPath=Path4;
InputInfo.BuildingInfo.Load.R1.FloorRange=[Input{7,3},Input{7,4}];
InputInfo.BuildingInfo.Load.R2.FloorRange=[Input{9,3},Input{9,4}];
InputInfo.BuildingInfo.Load.R3.FloorRange=[Input{11,3},Input{11,4}];
InputInfo.BuildingInfo.Load.R4.FloorRange=[Input{13,3},Input{13,4}];
% Load.mat file

if isstr(Path1)
    LoadPath1=xlsread(Path1);
    
    INDEX=find(isnan(LoadPath1)==1);
    LoadPath1(INDEX)=0;
    
    [row1,col1]=size(LoadPath1);
    if row1~=8760
        error ('please give load file in R1 with 8760 hour data!')
    end
    
    InputInfo.BuildingInfo.Load.R1.LoadData.Zone1=LoadPath1(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1:2);
    InputInfo.BuildingInfo.Load.R1.LoadData.Zone2=LoadPath1(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3:4);
    InputInfo.BuildingInfo.Load.R1.LoadData.Zone3=LoadPath1(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5:6);
    InputInfo.BuildingInfo.Load.R1.LoadData.Zone4=LoadPath1(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7:8);
    if col1>8
        InputInfo.BuildingInfo.Load.R1.LoadData.Zone5=LoadPath1(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9:10);
    else
        InputInfo.BuildingInfo.Load.R1.LoadData.Zone5=zeros(TimeStep,2);
    end
    
end

if isstr(Path2)
    LoadPath2=xlsread(Path2);
    
    INDEX=find(isnan(LoadPath2)==1);
    LoadPath2(INDEX)=0;
    
    [row2,col2]=size(LoadPath2);
    if row2~=8760
        error ('please give load file with 8760 hour data!')
    end
    
    InputInfo.BuildingInfo.Load.R2.LoadData.Zone1=LoadPath2(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1:2);
    InputInfo.BuildingInfo.Load.R2.LoadData.Zone2=LoadPath2(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3:4);
    InputInfo.BuildingInfo.Load.R2.LoadData.Zone3=LoadPath2(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5:6);
    InputInfo.BuildingInfo.Load.R2.LoadData.Zone4=LoadPath2(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7:8);
    if col2>8
        InputInfo.BuildingInfo.Load.R2.LoadData.Zone5=LoadPath2(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9:10);
    else
        InputInfo.BuildingInfo.Load.R2.LoadData.Zone5=zeros(TimeStep,2);
    end
    
end
if isstr(Path3)
    LoadPath3=xlsread(Path3);
    
    INDEX=find(isnan(LoadPath3)==1);
    LoadPath3(INDEX)=0;
    
    [row3,col3]=size(LoadPath3);
    if row3~=8760
        error ('please give load file in R3 with 8760 hour data!')
    end
    
    InputInfo.BuildingInfo.Load.R3.LoadData.Zone1=LoadPath3(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1:2);
    InputInfo.BuildingInfo.Load.R3.LoadData.Zone2=LoadPath3(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3:4);
    InputInfo.BuildingInfo.Load.R3.LoadData.Zone3=LoadPath3(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5:6);
    InputInfo.BuildingInfo.Load.R3.LoadData.Zone4=LoadPath3(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7:8);
    if col3>8
        InputInfo.BuildingInfo.Load.R3.LoadData.Zone5=LoadPath3(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9:10);
    else
        InputInfo.BuildingInfo.Load.R3.LoadData.Zone5=zeros(TimeStep,2);
    end
end
if isstr(Path4)
    LoadPath4=xlsread(Path4);
    
    INDEX=find(isnan(LoadPath4)==1);
    LoadPath4(INDEX)=0;
    
    [row4,col4]=size(LoadPath4);
    if row4~=8760
        error ('please give load file in R4 with 8760 hour data!')
    end  
    InputInfo.BuildingInfo.Load.R4.LoadData.Zone1=LoadPath4(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1:2);
    InputInfo.BuildingInfo.Load.R4.LoadData.Zone2=LoadPath4(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3:4);
    InputInfo.BuildingInfo.Load.R4.LoadData.Zone3=LoadPath4(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5:6);
    InputInfo.BuildingInfo.Load.R4.LoadData.Zone4=LoadPath4(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7:8);
    if col4>8
        InputInfo.BuildingInfo.Load.R4.LoadData.Zone5=LoadPath4(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9:10);
    else
        InputInfo.BuildingInfo.Load.R4.LoadData.Zone5=zeros(TimeStep,2);
    end
end


% check the topology range
InputInfo.BuildingInfo.TopologyRange=[Input{15,3}];

% check the equipment floor number
EquipNum=Input{16,3};
if length(EquipNum)~=1
    EquipNumCell=strsplit(EquipNum,',');
    EquipFloorNum=zeros(size(EquipNumCell));
    for i=1:size(EquipNumCell,2)
        EquipFloorNum(1,i)=str2num(EquipNumCell{1,i});
    end
else
    EquipFloorNum=EquipNum;
end
InputInfo.BuildingInfo.EquipFloorNum=EquipFloorNum;

%% Check Energy Stataion Information--Station 1
%                  ***
%               *********
%              ***Chiller***
%               *********
%                  ***
%*************************************************************************
%****************************Small Chiller*********************************
%**************************************************************************
%     CAPFT Curve
S1.Chiller.Small.CAPFTCoeff=[Input{21,5},Input{22,5},Input{23,5},Input{24,5},Input{25,5},Input{26,5}];
%     EIRFT Curve
S1.Chiller.Small.EIRFTCoeff=[Input{27,5},Input{28,5},Input{29,5},Input{30,5},Input{31,5},Input{32,5}];
%     EIRPLR Curve
S1.Chiller.Small.EIRPLRCoeff=[Input{33,5},Input{34,5},Input{35,5},Input{36,5}];
%     Design Capacity
S1.Chiller.Small.DesignCapacity=Input{37,4};
%     Design COP
S1.Chiller.Small.DesignCOP=Input{38,4};
%     Number
S1.Chiller.Small.ChillerNum=Input{39,4};
%     Motor Efficiency
S1.Chiller.Small.ChillerMotorEff=Input{40,4};
%*************************************************************************
%****************************Middle Chiller*******************************
%*************************************************************************
%     CAPFT Curve
S1.Chiller.Middle.CAPFTCoeff=[Input{41,5},Input{42,5},Input{43,5},Input{44,5},Input{45,5},Input{46,5}];
%     EIRFT Curve
S1.Chiller.Middle.EIRFTCoeff=[Input{47,5},Input{48,5},Input{49,5},Input{50,5},Input{51,5},Input{52,5}];
%     EIRPLR Curve
S1.Chiller.Middle.EIRPLRCoeff=[Input{53,5},Input{54,5},Input{55,5},Input{56,5}];
%     Design Capacity
S1.Chiller.Middle.DesignCapacity=Input{57,4};
%     Design COP
S1.Chiller.Middle.DesignCOP=Input{58,4};
%     Number
S1.Chiller.Middle.ChillerNum=Input{59,4};
%     Motor Efficiency
S1.Chiller.Middle.ChillerMotorEff=Input{60,4};
%*************************************************************************
%****************************Large Chiller********************************
%*************************************************************************
%     CAPFT Curve
S1.Chiller.Large.CAPFTCoeff=[Input{61,5},Input{62,5},Input{63,5},Input{64,5},Input{65,5},Input{66,5}];
%     EIRFT Curve
S1.Chiller.Large.EIRFTCoeff=[Input{67,5},Input{68,5},Input{69,5},Input{70,5},Input{71,5},Input{72,5}];
%     EIRPLR Curve
S1.Chiller.Large.EIRPLRCoeff=[Input{73,5},Input{74,5},Input{75,5},Input{76,5}];
%     Design Capacity
S1.Chiller.Large.DesignCapacity=Input{77,4};
%     Design COP
S1.Chiller.Large.DesignCOP=Input{78,4};
%     Number
S1.Chiller.Large.ChillerNum=Input{79,4};
%     Motor Efficiency
S1.Chiller.Large.ChillerMotorEff=Input{80,4};

%                  ***
%               *********
%           ***Primary Pump***
%               *********
%                  ***
%*************************************************************************
%****************************Small Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S1.PrimPump.Small.HeadSpdFlowCoeff=[Input{81,5},Input{82,5},Input{83,5},Input{84,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Small.EffSpdFlowCoeff=[Input{85,5},Input{86,5},Input{87,5},Input{88,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Small.MotorEffCoeff=[Input{89,5},Input{90,5}];
%     VFD Efficiency versus Speed
S1.PrimPump.Small.VFDEffCoeff=[Input{91,5},Input{92,5},Input{93,5},Input{94,5}];
%     Design Flow
S1.PrimPump.Small.DesignFlow=Input{95,4};
%     Design Head
S1.PrimPump.Small.DesignHead=Input{96,4};
%     Design Speed
S1.PrimPump.Small.Speed=Input{97,4};
%     Design Efficiency
S1.PrimPump.Small.Eff=Input{98,4};
%     IsVFD
S1.PrimPump.Small.IsVFD=Input{99,4};
%*************************************************************************
%****************************Middle Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S1.PrimPump.Middle.HeadSpdFlowCoeff=[Input{100,5},Input{101,5},Input{102,5},Input{103,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Middle.EffSpdFlowCoeff=[Input{104,5},Input{105,5},Input{106,5},Input{107,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Middle.MotorEffCoeff=[Input{108,5},Input{109,5}];
%     VFD Efficiency versus Speed
S1.PrimPump.Middle.VFDEffCoeff=[Input{110,5},Input{111,5},Input{112,5},Input{113,5}];
%     Design Flow
S1.PrimPump.Middle.DesignFlow=Input{114,4};
%     Design Head
S1.PrimPump.Middle.DesignHead=Input{115,4};
%     Design Speed
S1.PrimPump.Middle.Speed=Input{116,4};
%     Design Efficiency
S1.PrimPump.Middle.Eff=Input{117,4};
%     IsVFD
S1.PrimPump.Middle.IsVFD=Input{118,4};

%*************************************************************************
%****************************Large Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S1.PrimPump.Large.HeadSpdFlowCoeff=[Input{119,5},Input{120,5},Input{121,5},Input{122,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Large.EffSpdFlowCoeff=[Input{123,5},Input{124,5},Input{125,5},Input{126,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.PrimPump.Large.MotorEffCoeff=[Input{127,5},Input{128,5}];
%     VFD Efficiency versus Speed
S1.PrimPump.Large.VFDEffCoeff=[Input{129,5},Input{130,5},Input{131,5},Input{132,5}];
%     Design Flow
S1.PrimPump.Large.DesignFlow=Input{133,4};
%     Design Head
S1.PrimPump.Large.DesignHead=Input{134,4};
%     Design Speed
S1.PrimPump.Large.Speed=Input{135,4};
%     IsVFD
S1.PrimPump.Large.IsVFD=Input{136,4};
%     Design Efficiency
S1.PrimPump.Large.Eff=Input{137,4};


%                  ************
%               *******************
%           ***Second Pump AHU Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S1.SecPumpAHUZone1.HeadSpdFlowCoeff=[Input{138,5},Input{139,5},Input{140,5},Input{141,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone1.EffSpdFlowCoeff=[Input{142,5},Input{143,5},Input{144,5},Input{145,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone1.MotorEffCoeff=[Input{146,5},Input{147,5}];
%     VFD Efficiency versus Speed
S1.SecPumpAHUZone1.VFDEffCoeff=[Input{148,5},Input{149,5},Input{150,5},Input{151,5}];
%     Design Flow
S1.SecPumpAHUZone1.DesignFlow=Input{152,3};
%     Design Head
S1.SecPumpAHUZone1.DesignHead=Input{153,3};
%     Design Speed
S1.SecPumpAHUZone1.Speed=Input{154,3};
%     Number
S1.SecPumpAHUZone1.Number=Input{155,3};
%     IsVFD
S1.SecPumpAHUZone1.IsVFD=Input{156,3};
%     Design Efficiency
S1.SecPumpAHUZone1.Eff=Input{157,3};


%                  ************
%               *******************
%           ***Second Pump HX Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S1.SecPumpHXZone1.HeadSpdFlowCoeff=[Input{158,5},Input{159,5},Input{160,5},Input{161,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.SecPumpHXZone1.EffSpdFlowCoeff=[Input{162,5},Input{163,5},Input{164,5},Input{165,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.SecPumpHXZone1.MotorEffCoeff=[Input{166,5},Input{167,5}];
%     VFD Efficiency versus Speed
S1.SecPumpHXZone1.VFDEffCoeff=[Input{168,5},Input{169,5},Input{170,5},Input{171,5}];
%     Design Flow
S1.SecPumpHXZone1.DesignFlow=Input{172,3};
%     Design Head
S1.SecPumpHXZone1.DesignHead=Input{173,3};
%     Design Speed
S1.SecPumpHXZone1.Speed=Input{174,3};
%     Number
S1.SecPumpHXZone1.Number=Input{175,3};
%     IsVFD
S1.SecPumpHXZone1.IsVFD=Input{176,3};
%     Design Efficiency
S1.SecPumpHXZone1.Eff=Input{177,3};


%                  ************
%               *******************
%           *******Heat Exchanger1*******
%               ********************
%                  *************
S1.HX1.UAParameter=[Input{179,4},Input{180,4}];
S1.HX1.DesignFlow=Input{181,3};
S1.HX1.Number=Input{182,3};

%                  ************
%               *******************
%           ***Second Pump AHU Zone2***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S1.SecPumpAHUZone2.HeadSpdFlowCoeff=[Input{183,5},Input{184,5},Input{185,5},Input{186,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone1.EffSpdFlowCoeff=[Input{187,5},Input{188,5},Input{189,5},Input{190,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone1.MotorEffCoeff=[Input{191,5},Input{192,5}];
%     VFD Efficiency versus Speed
S1.SecPumpAHUZone1.VFDEffCoeff=[Input{193,5},Input{194,5},Input{195,5},Input{196,5}];
%     Design Flow
S1.SecPumpAHUZone1.DesignFlow=Input{197,3};
%     Design Head
S1.SecPumpAHUZone1.DesignHead=Input{198,3};
%     Design Speed
S1.SecPumpAHUZone1.Speed=Input{199,3};
%     Number
S1.SecPumpAHUZone1.Number=Input{200,3};
%     IsVFD
S1.SecPumpAHUZone1.IsVFD=Input{201,3};
%     Design Efficiency
S1.SecPumpAHUZone1.Eff=Input{202,3};


%                  ************
%               *******************
%           ***Second Pump HX Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S1.SecPumpHXZone2.HeadSpdFlowCoeff=[Input{203,5},Input{204,5},Input{205,5},Input{206,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.SecPumpHXZone2.EffSpdFlowCoeff=[Input{207,5},Input{208,5},Input{209,5},Input{210,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.SecPumpHXZone2.MotorEffCoeff=[Input{211,5},Input{212,5}];
%     VFD Efficiency versus Speed
S1.SecPumpHXZone2.VFDEffCoeff=[Input{213,5},Input{214,5},Input{215,5},Input{216,5}];
%     Design Flow
S1.SecPumpHXZone2.DesignFlow=Input{217,3};
%     Design Head
S1.SecPumpHXZone2.DesignHead=Input{218,3};
%     Design Speed
S1.SecPumpHXZone2.Speed=Input{219,3};
%     Number
S1.SecPumpHXZone2.Number=Input{220,3};
%     IsVFD
S1.SecPumpHXZone2.IsVFD=Input{221,3};
%     Design Efficiency
S1.SecPumpHXZone2.Eff=Input{223,3};


%                  ************
%               *******************
%           *******Heat Exchanger2*******
%               ********************
%                  *************
S1.HX2.UAParameter=[Input{224,4},Input{225,4}];
S1.HX2.DesignFlow=Input{226,3};
S1.HX2.Number=Input{227,3};

%                  ************
%               *******************
%           ***Second Pump AHU Zone3***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S1.SecPumpAHUZone3.HeadSpdFlowCoeff=[Input{228,5},Input{229,5},Input{230,5},Input{231,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone3.EffSpdFlowCoeff=[Input{232,5},Input{233,5},Input{234,5},Input{235,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S1.SecPumpAHUZone3.MotorEffCoeff=[Input{236,5},Input{237,5}];
%     VFD Efficiency versus Speed
S1.SecPumpAHUZone3.VFDEffCoeff=[Input{238,5},Input{239,5},Input{240,5},Input{241,5}];
%     Design Flow
S1.SecPumpAHUZone3.DesignFlow=Input{242,3};
%     Design Head
S1.SecPumpAHUZone3.DesignHead=Input{243,3};
%     Design Speed
S1.SecPumpAHUZone3.Speed=Input{244,3};
%     Number
S1.SecPumpAHUZone3.Number=Input{245,3};
%     IsVFD
S1.SecPumpAHUZone3.IsVFD=Input{246,3};
%     Design Efficiency
S1.SecPumpAHUZone3.Eff=Input{247,3};


%% Check Energy Stataion Information--Station 2
%                  ***
%               *********
%              ***Chiller***
%               *********
%                  ***
%*************************************************************************
%****************************Small Chiller*********************************
%**************************************************************************
%     CAPFT Curve
S2.Chiller.Small.CAPFTCoeff=[Input{249,5},Input{250,5},Input{251,5},Input{252,5},Input{253,5},Input{254,5}];
%     EIRFT Curve
S2.Chiller.Small.EIRFTCoeff=[Input{255,5},Input{256,5},Input{257,5},Input{258,5},Input{259,5},Input{260,5}];
%     EIRPLR Curve
S2.Chiller.Small.EIRPLRCoeff=[Input{261,5},Input{262,5},Input{263,5},Input{264,5}];
%     Design Capacity
S2.Chiller.Small.DesignCapacity=Input{265,4};
%     Design COP
S2.Chiller.Small.DesignCOP=Input{266,4};
%     Number
S2.Chiller.Small.ChillerNum=Input{267,4};
%     Motor Efficiency
S2.Chiller.Small.ChillerMotorEff=Input{268,4};
%*************************************************************************
%****************************Middle Chiller*******************************
%*************************************************************************
%     CAPFT Curve
S2.Chiller.Middle.CAPFTCoeff=[Input{269,5},Input{270,5},Input{271,5},Input{272,5},Input{273,5},Input{274,5}];
%     EIRFT Curve
S2.Chiller.Middle.EIRFTCoeff=[Input{275,5},Input{276,5},Input{277,5},Input{278,5},Input{279,5},Input{280,5}];
%     EIRPLR Curv
S2.Chiller.Middle.EIRPLRCoeff=[Input{281,5},Input{282,5},Input{283,5},Input{284,5}];
%     Design Capacit
S2.Chiller.Middle.DesignCapacity=Input{285,4};
%     Design COP
S2.Chiller.Middle.DesignCOP=Input{286,4};
%     Number
S2.Chiller.Middle.ChillerNum=Input{287,4};
%     Motor Efficiency
S2.Chiller.Middle.ChillerMotorEff=Input{288,4};
%*************************************************************************
%****************************Large Chiller********************************
%*************************************************************************
%     CAPFT Curve
S2.Chiller.Large.CAPFTCoeff=[Input{289,5},Input{290,5},Input{291,5},Input{292,5},Input{293,5},Input{294,5}];
%     EIRFT Curve
S2.Chiller.Large.EIRFTCoeff=[Input{295,5},Input{296,5},Input{297,5},Input{298,5},Input{299,5},Input{300,5}];
%     EIRPLR Curve
S2.Chiller.Large.EIRPLRCoeff=[Input{301,5},Input{302,5},Input{303,5},Input{304,5}];
%     Design Capacity
S2.Chiller.Large.DesignCapacity=Input{305,4};
%     Design COP
S2.Chiller.Large.DesignCOP=Input{306,4};
%     Number
S2.Chiller.Large.ChillerNum=Input{307,4};
%     Motor Efficiency
S2.Chiller.Large.ChillerMotorEff=Input{308,4};


%                  ***
%               *********
%           ***Primary Pump***
%               *********
%                  ***
%*************************************************************************
%****************************Small Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S2.PrimPump.Small.HeadSpdFlowCoeff=[Input{309,5},Input{310,5},Input{311,5},Input{312,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Small.EffSpdFlowCoeff=[Input{313,5},Input{314,5},Input{315,5},Input{316,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Small.MotorEffCoeff=[Input{317,5},Input{318,5}];
%     VFD Efficiency versus Speed
S2.PrimPump.Small.VFDEffCoeff=[Input{319,5},Input{320,5},Input{321,5},Input{322,5}];
%     Design Flow
S2.PrimPump.Small.DesignFlow=Input{323,4};
%     Design Head
S2.PrimPump.Small.DesignHead=Input{324,4};
%     Design Speed
S2.PrimPump.Small.Speed=Input{325,4};
%     IsVFD
S2.PrimPump.Small.IsVFD=Input{326,4};
%     Design Efficiency
S2.PrimPump.Small.Eff=Input{327,4};

%*************************************************************************
%****************************Middle Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S2.PrimPump.Middle.HeadSpdFlowCoeff=[Input{328,5},Input{329,5},Input{330,5},Input{331,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Middle.EffSpdFlowCoeff=[Input{332,5},Input{333,5},Input{334,5},Input{335,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Middle.MotorEffCoeff=[Input{336,5},Input{337,5}];
%     VFD Efficiency versus Speed
S2.PrimPump.Middle.VFDEffCoeff=[Input{338,5},Input{339,5},Input{340,5},Input{341,5}];
%     Design Flow
S2.PrimPump.Middle.DesignFlow=Input{342,4};
%     Design Head
S2.PrimPump.Middle.DesignHead=Input{343,4};
%     Design Speed
S2.PrimPump.Middle.Speed=Input{344,4};
%     IsVFD
S2.PrimPump.Middle.IsVFD=Input{345,4};
%     Design Efficiency
S2.PrimPump.Middle.Eff=Input{346,4};


%*************************************************************************
%****************************Large Primary*********************************
%**************************************************************************
%     Head versus Speed and Flowrate Curve
S2.PrimPump.Large.HeadSpdFlowCoeff=[Input{347,5},Input{348,5},Input{349,5},Input{350,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Large.EffSpdFlowCoeff=[Input{351,5},Input{352,5},Input{353,5},Input{354,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.PrimPump.Large.MotorEffCoeff=[Input{355,5},Input{356,5}];
%     VFD Efficiency versus Speed
S2.PrimPump.Large.VFDEffCoeff=[Input{357,5},Input{358,5},Input{359,5},Input{360,5}];
%     Design Flow
S2.PrimPump.Large.DesignFlow=Input{361,4};
%     Design Head
S2.PrimPump.Large.DesignHead=Input{362,4};
%     Design Speed
S2.PrimPump.Large.Speed=Input{363,4};
%     IsVFD
S2.PrimPump.Large.IsVFD=Input{364,4};
%     Design Efficiency
S2.PrimPump.Large.Eff=Input{365,4};


%                  ************
%               *******************
%           ***Second Pump AHU Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S2.SecPumpAHUZone1.HeadSpdFlowCoeff=[Input{366,5},Input{367,5},Input{368,5},Input{369,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone1.EffSpdFlowCoeff=[Input{370,5},Input{371,5},Input{372,5},Input{373,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone1.MotorEffCoeff=[Input{374,5},Input{375,5}];
%     VFD Efficiency versus Speed
S2.SecPumpAHUZone1.VFDEffCoeff=[Input{376,5},Input{377,5},Input{378,5},Input{379,5}];
%     Design Flow
S2.SecPumpAHUZone1.DesignFlow=Input{380,3};
%     Design Head
S2.SecPumpAHUZone1.DesignHead=Input{381,3};
%     Design Speed
S2.SecPumpAHUZone1.Speed=Input{382,3};
%     Number
S2.SecPumpAHUZone1.Number=Input{383,3};
%     IsVFD
S2.SecPumpAHUZone1.IsVFD=Input{384,3};
%     Design Efficiency
S2.SecPumpAHUZone1.Eff=Input{385,3};


%                  ************
%               *******************
%           ***Second Pump HX Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S2.SecPumpHXZone1.HeadSpdFlowCoeff=[Input{386,5},Input{387,5},Input{388,5},Input{389,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.SecPumpHXZone1.EffSpdFlowCoeff=[Input{390,5},Input{391,5},Input{392,5},Input{393,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.SecPumpHXZone1.MotorEffCoeff=[Input{394,5},Input{395,5}];
%     VFD Efficiency versus Speed
S2.SecPumpHXZone1.VFDEffCoeff=[Input{396,5},Input{397,5},Input{398,5},Input{399,5}];
%     Design Flow
S2.SecPumpHXZone1.DesignFlow=Input{400,3};
%     Design Head
S2.SecPumpHXZone1.DesignHead=Input{401,3};
%     Design Speed
S2.SecPumpHXZone1.Speed=Input{402,3};
%     Number
S2.SecPumpHXZone1.Number=Input{403,3};
%     IsVFD
S2.SecPumpHXZone1.IsVFD=Input{404,3};
%     Design Efficiency
S2.SecPumpHXZone1.Eff=Input{405,3};


%                  ************
%               *******************
%           *******Heat Exchanger1*******
%               ********************
%                  *************
S2.HX1.UAParameter=[Input{407,4},Input{408,4}];
S2.HX1.DesignFlow=Input{409,3};
S2.HX1.Number=Input{410,3};

%                  ************
%               *******************
%           ***Second Pump AHU Zone2***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S2.SecPumpAHUZone2.HeadSpdFlowCoeff=[Input{411,5},Input{412,5},Input{413,5},Input{414,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone2.EffSpdFlowCoeff=[Input{415,5},Input{416,5},Input{417,5},Input{418,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone2.MotorEffCoeff=[Input{419,5},Input{420,5}];
%     VFD Efficiency versus Speed
S2.SecPumpAHUZone2.VFDEffCoeff=[Input{421,5},Input{422,5},Input{423,5},Input{424,5}];
%     Design Flow
S2.SecPumpAHUZone2.DesignFlow=Input{425,3};
%     Design Head
S2.SecPumpAHUZone2.DesignHead=Input{426,3};
%     Design Speed
S2.SecPumpAHUZone2.Speed=Input{427,3};
%     Number
S2.SecPumpAHUZone2.Number=Input{428,3};
%     IsVFD
S2.SecPumpAHUZone2.IsVFD=Input{429,3};
%     Design Efficiency
S2.SecPumpAHUZone2.Eff=Input{430,3};


%                  ************
%               *******************
%           ***Second Pump HX Zone1***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S2.SecPumpHXZone2.HeadSpdFlowCoeff=[Input{431,5},Input{432,5},Input{433,5},Input{434,5}];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.SecPumpHXZone2.EffSpdFlowCoeff=[Input{435,5},Input{436,5},Input{437,5},Input{438,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.SecPumpHXZone2.MotorEffCoeff=[Input{439,5},Input{440,5}];
%     VFD Efficiency versus Speed
S2.SecPumpHXZone2.VFDEffCoeff=[Input{441,5},Input{442,5},Input{443,5},Input{444,5}];
%     Design Flow
S2.SecPumpHXZone2.DesignFlow=Input{445,3};
%     Design Head
S2.SecPumpHXZone2.DesignHead=Input{446,3};
%     Design Speed
S2.SecPumpHXZone2.Speed=Input{447,3};
%     Number
S2.SecPumpHXZone2.Number=Input{448,3};
%     IsVFD
S2.SecPumpHXZone2.IsVFD=Input{449,3};
%     Design Efficiency
S2.SecPumpHXZone2.Eff=Input{450,3};


%                  ************
%               *******************
%           *******Heat Exchanger2*******
%               ********************
%                  *************
S2.HX2.UAParameter=[Input{452,4},Input{453,4}];
S2.HX2.DesignFlow=Input{454,3};
S2.HX2.Number=Input{455,3};

%                  ************
%               *******************
%           ***Second Pump AHU Zone3***
%               ********************
%                  *************
%     Head versus Speed and Flowrate Curve
S2.SecPumpAHUZone3.HeadSpdFlowCoeff=[Input{456,5},Input{457,5},Input{458,5},Input{459,5},];
%     Wheel Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone3.EffSpdFlowCoeff=[Input{460,5},Input{461,5},Input{462,5},Input{463,5}];
%     Motor Efficiency versus Speed and Flowrate Curve
S2.SecPumpAHUZone3.MotorEffCoeff=[Input{464,5},Input{465,5}];
%     VFD Efficiency versus Speed
S2.SecPumpAHUZone3.VFDEffCoeff=[Input{466,5},Input{467,5},Input{468,5},Input{469,5}];
%     Design Flow
S2.SecPumpAHUZone3.DesignFlow=Input{470,3};
%     Design Head
S2.SecPumpAHUZone3.DesignHead=Input{471,3};
%     Design Speed
S2.SecPumpAHUZone3.Speed=Input{472,3};
%     Number
S2.SecPumpAHUZone3.Number=Input{473,3};
%     IsVFD
S2.SecPumpAHUZone3.IsVFD=Input{474,3};
%     Design Efficiency
S2.SecPumpAHUZone3.Eff=Input{475,3};

%% Cooling tower cell
InputInfo.CT.CTCellNominalHeatFlow=Input{476,3};
InputInfo.CT.CTCellNominalAirFlow=Input{477,3};
InputInfo.CT.CTCellNominalWaterFlow=Input{478,3};
InputInfo.CT.CTCellNominalPower=Input{479,3};

%% Design Information
% HVAC system parameter
InputInfo.HVACSetting.OARatio=Input{481,3}/100;
InputInfo.HVACSetting.ChilledWaterTempDiff=Input{482,3};
InputInfo.HVACSetting.CondWaterTempDiff=Input{483,3};
InputInfo.HVACSetting.HeatingWaterTempDiff=Input{484,3};
InputInfo.HVACSetting.AHUOutletTempSetPoint=Input{485,3};
InputInfo.HVACSetting.SupplyChilledWaterTemp=Input{486,3};
InputInfo.HVACSetting.ReturnCondWaterTemp=Input{487,3};
InputInfo.HVACSetting.SupplyHeatWaterTemp=Input{488,3};
InputInfo.HVACSetting.DesignPressureIndex=Input{489,3};

% Outdoor Parameter
InputInfo.HVACSetting.City=Input{490,3};

% Indoor Parameter
InputInfo.HVACSetting.DesignCri.temp=Input{491,3};
InputInfo.HVACSetting.DesignCri.RH=Input{492,3}/100;



InputInfo.S1=S1;
InputInfo.S2=S2;

end
