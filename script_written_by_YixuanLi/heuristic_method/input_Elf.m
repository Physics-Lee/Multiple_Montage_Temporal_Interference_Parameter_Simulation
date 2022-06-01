function Elf = input_Elf(input,elec4,n_interest)
    U = temp_T2U(elec4.T(n_interest,:));
    Elf = temp_onetime(input,U);
end