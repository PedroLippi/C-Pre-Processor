::Start::
Texto=nil
Arquivo=""
print("Arquivo C:")
repeat
	Arquivo=io.read("*l")
	if Arquivo=="0" then
		os.exit()
	end
	Texto=io.open(Arquivo,"r")
until type(Texto)=="userdata"

Pre=""
Definicoes={}
while Texto:read(0)~=nil do
	local Letra=Texto:read(1)
	if Letra=="#" then
		local Palavra=Texto:read(7)
		if Palavra==("include") then
			repeat
				Letra=Texto:read(1)
			until Letra~="<" and Letra~="\"" and Letra~="\n"
			Palavra=""
			Texto:read(1)
			repeat
				Letra=Texto:read(1)
				Palavra=Palavra..Letra
			until Letra==">" or Letra=="\""
			Palavra=string.sub(Palavra,1,-2)
			local Biblioteca
			if Letra==">" then
				Biblioteca=io.open("/usr/include/"..Palavra,"r")
			elseif Letra=="\"" then
				Biblioteca=io.open(Palavra,"r")
			end
			Pre=Biblioteca:read("*all")..Pre
			
		elseif Palavra==("define ") then
			Palavra=""
			repeat
				Letra=Texto:read(1)
				Palavra=Palavra..Letra
			until Letra==" "
			Palavra=string.sub(Palavra,1,-2)
			Definicoes[#Definicoes+1]=Palavra
			Palavra=""
			repeat
				Letra=Texto:read(1)
				Palavra=Palavra..Letra
			until Letra=="\n"
			Palavra=string.sub(Palavra,1,-2)
			Definicoes[#Definicoes+1]=Palavra
			
		else
			Texto:seek("cur",-7)
			Pre=Pre.."#"
		end
	else
		Pre=Pre..Letra
	end
end

for i=1,#Definicoes,2 do
	Pre=string.gsub(Pre,Definicoes[i],Definicoes[i+1])
end

Pre=string.gsub(Pre,"/%*.-%*/","")
Pre=string.gsub(Pre,"//.-[\n\r]","")

BS=[[\]]
Pre=string.gsub(Pre,BS.."([\n\r][^\n\r]-)[\n\r]",BS.."%1PULARlinhaAQUI")
Pre=string.gsub(Pre,"(#[^\n\r]-)[\n\r]","%1PULARlinhaAQUI")
Pre=string.gsub(Pre,"[\n\r]([^\n\r]-#)","PULARlinhaAQUI%1")
Pre=string.gsub(Pre,"[\n\r]"," ")
Pre=string.gsub(Pre,"JOGOdaVELHA","#")
Pre=string.gsub(Pre,"PULARlinhaAQUI","\n")

Pre=string.gsub(Pre,"(#[^\n\r]-)%s(%()","%1ESpaCO%2")

Pre=string.gsub(Pre,"\t"," ")
while string.find(Pre,"  ") do
	Pre=string.gsub(Pre,"  "," ")
end

Normal={";","=","<",">","{","}",",","!","&","|","]"}
for i=1,#Normal do
	Pre=string.gsub(Pre,Normal[i].." ",Normal[i])
	Pre=string.gsub(Pre," "..Normal[i],Normal[i])
end
Especial={"(",")","-","+","[","*"}
for i=1,#Especial do
	Pre=string.gsub(Pre,"%"..Especial[i].." ",Especial[i])
	Pre=string.gsub(Pre," ".."%"..Especial[i],Especial[i])
end
Pre=string.gsub(Pre,"ESpaCO"," ")

Pre=string.gsub(Pre,"([\n\r]) ","%1")
Pre=string.gsub(Pre,"([\n\r])[\n\r]","%1")

Novo=io.open("Pre"..Arquivo,"w")
Novo:write(Pre)
Texto:close()
Novo:close()
print("pre"..Arquivo.." criado.")

goto Start
