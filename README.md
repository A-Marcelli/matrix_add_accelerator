# matrix_add_accelerator
Matrix addition accelerator for the Disa2 project.

## Folder Structure
- Docs: Contains the pdf report summarising the work carried out, the .drawio files from which the images were taken and the images of the architecture, ASM and waves in simulation.
- Script_matlab: Contains a matlab script to generate 2 matrixes of user chosen dimensions and the sum of the two, to check the results after simulation.
- Source: Contains all the source VHDL files of the accelerator, including the top and the external ram.
- Testbench: Contains all the testbench used to test the accelerator. There is a testbench for every entity and 3 complete ones. The "testbench.vhd" is the main one and the "tb_wrapper_verilog.v" is used for post-synthesis simulation as vivado does not accept VHDL testbench for this case. It also contains example input files.
