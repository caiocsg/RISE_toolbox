%% Code automagically generated by rise on 05-Jan-2013 01:28:39

function [Jac_]=endo_exo_derivatives(y,x,param,ss,def)

Jac_=zeros(8,20);
bigi_=speye(20);
indx_1_=[1,2,3,5,6];
Jac_(1,indx_1_)=((-bigi_(6,indx_1_))./(y(6).^2))-(((((bigi_(5,indx_1_).*((1+y(3))-y(2)))+((bigi_(3,indx_1_)-bigi_(2,indx_1_)).*y(5))).*y(1))-(bigi_(1,indx_1_).*(y(5).*((1+y(3))-y(2)))))./(y(1).^2));
indx_2_=[4,6,7,8,9,15];
ref_23_=param(1)-1;
ref_28_=1-param(1);
Jac_(2,indx_2_)=(bigi_(6,indx_2_)+bigi_(9,indx_2_))-(((((bigi_(4,indx_2_).*(y(15).^param(1)))+(((param(1).*bigi_(15,indx_2_)).*(y(15).^ref_23_)).*y(4))).*(y(8).^ref_28_))+(((ref_28_.*bigi_(8,indx_2_)).*(y(8).^(ref_28_-1))).*(y(4).*(y(15).^param(1)))))+(((-bigi_(7,indx_2_)).*y(15))+(bigi_(15,indx_2_).*(1-y(7)))));
indx_3_=[4,6,8,10,15];
ref_47_=y(15)./y(8);
Jac_(3,indx_3_)=((((((bigi_(4,indx_3_).*ref_28_).*(ref_47_.^param(1)))+(((param(1).*(((bigi_(15,indx_3_).*y(8))-(bigi_(8,indx_3_).*y(15)))./(y(8).^2))).*(ref_47_.^ref_23_)).*(ref_28_.*y(4)))).*y(6))-(bigi_(6,indx_3_).*((ref_28_.*y(4)).*(ref_47_.^param(1)))))./(y(6).^2))-(((bigi_(10,indx_3_).*(1-y(8)))-((-bigi_(8,indx_3_)).*y(10)))./((1-y(8)).^2));
indx_4_=[4,8,11,15];
Jac_(4,indx_4_)=bigi_(11,indx_4_)-(((bigi_(4,indx_4_).*param(1)).*(ref_47_.^ref_23_))+(((ref_23_.*(((bigi_(15,indx_4_).*y(8))-(bigi_(8,indx_4_).*y(15)))./(y(8).^2))).*(ref_47_.^(ref_23_-1))).*(param(1).*y(4))));
indx_5_=[4,12,17];
Jac_(5,indx_5_)=(bigi_(4,indx_5_)./y(4))-(((bigi_(12,indx_5_)./y(12)).*param(5))+(bigi_(17,indx_5_).*param(9)));
indx_6_=[5,13,18];
Jac_(6,indx_6_)=(((bigi_(5,indx_6_).*param(2))./(param(2).^2))./(y(5)./param(2)))-(((((bigi_(13,indx_6_).*param(2))./(param(2).^2))./(y(13)./param(2))).*param(6))+(bigi_(18,indx_6_).*param(10)));
indx_7_=[7,14,19];
Jac_(7,indx_7_)=(((bigi_(7,indx_7_).*param(3))./(param(3).^2))./(y(7)./param(3)))-(((((bigi_(14,indx_7_).*param(3))./(param(3).^2))./(y(14)./param(3))).*param(7))+(bigi_(19,indx_7_).*param(11)));
indx_8_=[10,16,20];
Jac_(8,indx_8_)=(((bigi_(10,indx_8_).*param(4))./(param(4).^2))./(y(10)./param(4)))-(((((bigi_(16,indx_8_).*param(4))./(param(4).^2))./(y(16)./param(4))).*param(8))+(bigi_(20,indx_8_).*param(12)));
