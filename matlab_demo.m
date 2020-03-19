


filename='D:\VM-ADCP_documentation\demo_cruise\ADCP\os150_ENR\contour\os150.nc'

info=ncinfo(filename);
clear data_struct

for i=1:size(info.Variables,2)
   variables_to_load{i}=info.Variables(i).Name;
end

% loop over the variables
for j=1:numel(variables_to_load)
    % extract the jth variable (type = string)
    var = variables_to_load{j};

    % use dynamic field name to add this to the structure
    data_struct.(var) = ncread(filename,var);

    % convert from single to double, if that matters to you (it does to me)
    if isa(data_struct.(var),'single')
        data_struct.(var) = double(data_struct.(var));
    end
end

data_struct.u(data_struct.u>10)=NaN;
data_struct.v(data_struct.v>10)=NaN;
data_struct.lat(data_struct.lat>100)=NaN;
data_struct.lon(data_struct.lon>400)=NaN;
data_struct.depth(data_struct.depth>15000)=NaN;

%%

addpath(genpath('C:\Users\a5278\Documents\MATLAB\matlab_functions'))

latlim=[min(data_struct.lat)-1 max(data_struct.lat)+1];
lonlim=[min(data_struct.lon)-1 max(data_struct.lon)+1];

figure(3)
clf
set(gcf,'color',[1 1 1])
hold on
m_proj('lambert','long',lonlim,'lat',latlim);
m_gshhs_l('patch',[.8 .8 .8]);
 m_grid('xlabeldir','end','fontsize',10);
 
m_vec(1,data_struct.lon(1:3:end),data_struct.lat(1:3:end),mean(data_struct.u(:,1:3:end),'omitnan'),mean(data_struct.v(:,1:3:end),'omitnan'),data_struct.tr_temp(1:3:end),'shaftwidth', .8, 'headangle', 35, 'edgeclip', 'on')

cb=colorbar
ylabel(cb,'Transducer temperature in ^{\circ} C')
m_plot(data_struct.lon,data_struct.lat,'.k')

%   print(gcf,'-dpng',['vmadcp_map_vectors'],'-r400') 

%%


clear tide
addpath(genpath('C:\Users\a5278\Documents\MATLAB\tidal_model'))
Model='C:\Users\a5278\Documents\MATLAB\tidal_model\aotim5_tmd\Model_AOTIM5';
[tide.u_arc,a]=tmd_tide_pred(Model,data_struct.time,data_struct.lat,data_struct.lon,'u',[]);
[tide.v_arc,a]=tmd_tide_pred(Model,data_struct.time,data_struct.lat,data_struct.lon,'v',[]);

Model='C:\Users\a5278\Documents\MATLAB\tidal_model\atlantic\Model_AO';
[tide.u_atl,a]=tmd_tide_pred(Model,data_struct.time,data_struct.lat,data_struct.lon,'u',[]);
[tide.v_atl,a]=tmd_tide_pred(Model,data_struct.time,data_struct.lat,data_struct.lon,'v',[]);

tide.u_arc=tide.u_arc./100;
tide.v_arc=tide.v_arc./100;
tide.u_atl=tide.u_atl./100;
tide.v_atl=tide.v_atl./100;

tide.u=tide.u_arc;
tide.u(isnan(tide.u))=tide.u_atl(isnan(tide.u));
tide.v=tide.u_arc;
tide.v(isnan(tide.v))=tide.v_atl(isnan(tide.v));

data_struct.u_detide=data_struct.u - repmat(tide.u,[ size(data_struct.u,1),1 ]) ;
data_struct.v_detide=data_struct.v - repmat(tide.v,[ size(data_struct.v,1),1 ]) ;

%%

addpath(genpath('C:\Users\a5278\Documents\MATLAB\matlab_functions'))

latlim=[min(data_struct.lat)-1 max(data_struct.lat)+1];
lonlim=[min(data_struct.lon)-1 max(data_struct.lon)+1];

figure(3)
clf
set(gcf,'color',[1 1 1])
hold on
m_proj('lambert','long',lonlim,'lat',latlim);
m_gshhs_l('patch',[.8 .8 .8]);
 m_grid('xlabeldir','end','fontsize',10);
 
m_vec(1,data_struct.lon(1:3:end),data_struct.lat(1:3:end),mean(data_struct.u_detide(:,1:3:end),'omitnan'),mean(data_struct.v_detide(:,1:3:end),'omitnan'),data_struct.tr_temp(1:3:end),'shaftwidth', .8, 'headangle', 35, 'edgeclip', 'on')

cb=colorbar
ylabel(cb,'Transducer temperature in ^{\circ} C')
m_plot(data_struct.lon,data_struct.lat,'.k')

%   print(gcf,'-dpng',['vmadcp_map_vectors_detide'],'-r400') 

%% cut out data close to land using Etopo 1 depth data

latlim=[min(data_struct.lat)-1 max(data_struct.lat)+1];
lonlim=[min(data_struct.lon)-1 max(data_struct.lon)+1];

[Z, refvec] = etopo('C:\Users\a5278\Documents\MATLAB\ETOPO\etopo1_ice_c_f4.flt', 1, latlim, lonlim);

depth_threshold=-10;

data_struct.bottomdepth = ltln2val(Z, refvec, data_struct.lat, data_struct.lon);

data_struct.u_detide_clean=data_struct.u_detide;
data_struct.v_detide_clean=data_struct.v_detide;

ix=data_struct.bottomdepth>depth_threshold;
data_struct.u_detide_clean(:,ix)=NaN([100,sum(ix)]);
data_struct.v_detide_clean(:,ix)=NaN([100,sum(ix)]);

%% map it
addpath(genpath('C:\Users\a5278\Documents\MATLAB\matlab_functions'))

latlim=[min(data_struct.lat)-1 max(data_struct.lat)+1];
lonlim=[min(data_struct.lon)-1 max(data_struct.lon)+1];

figure(3)
clf
set(gcf,'color',[1 1 1])
hold on
m_proj('lambert','long',lonlim,'lat',latlim);
m_gshhs_l('patch',[.8 .8 .8]);
 m_grid('xlabeldir','end','fontsize',10);
 
m_vec(1,data_struct.lon(1:3:end),data_struct.lat(1:3:end),mean(data_struct.u_detide_clean(:,1:3:end),'omitnan'),mean(data_struct.v_detide_clean(:,1:3:end),'omitnan'),data_struct.tr_temp(1:3:end),'shaftwidth', .8, 'headangle', 35, 'edgeclip', 'on')

cb=colorbar
ylabel(cb,'Transducer temperature in ^{\circ} C')
m_plot(data_struct.lon,data_struct.lat,'.k')

%   print(gcf,'-dpng',['vmadcp_map_vectors_detide_clean'],'-r400') 


