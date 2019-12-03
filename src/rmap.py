import sys
import numpy as np
from create_template import define_templates
from T6_PSI_settings import T6_PSI_settings
from simulated_annealer import simulated_annealer
from construct_eqn import construct_eqn
from scipy import sparse as sparse_mat
import matplotlib.image as img
import math
import time
import re
from template_construction import template_def
from tqdm import tqdm


def main():
    eq_obj = construct_eqn()
    settings_obj = T6_PSI_settings()
    
    template_list = define_templates(settings_obj, generate_g=0)

    template_obj = template_list[2]
    g_start = template_obj.start
    G = template_obj.G


    pitch_bot = template_obj.pitches[0]
    dir_bot = template_obj.dirs[0]
    offset_bot = template_obj.offset[0]
    node_vdd = np.column_stack(((np.round((settings_obj.LENGTH_REGION/2)/ \
               template_obj.xpitch)),(np.round((settings_obj.WIDTH_REGION/2)/template_obj.y_pitch))))
    print(node_vdd)
    vdds = np.zeros((G.shape[0], 1))
    #vdds[(math.floor(template_def.convert_index(template_obj,node_vdd[0,0], node_vdd[0,1]))), 0] = 1
    vdds[(math.floor(template_def.convert_index(template_obj,node_vdd[0,0], node_vdd[0,1]))), 0] = 1
    addn_zeros = sparse_mat.dok_matrix(np.zeros((1, 1)))
    vdds = sparse_mat.dok_matrix(vdds)
    g_size = G.shape[0]
    print(G.shape)
    G = sparse_mat.bmat([[G, vdds], [np.transpose(vdds), addn_zeros]])
    J_add_vdds = settings_obj.VDD * np.ones([1, 1])
    bot_lay = g_start[1][0]
    max_drop = settings_obj.VDD * np.ones(bot_lay)
    s_time = time.time()
    dimx = template_obj.num_x
    dimy = template_obj.num_y
    print((math.floor(template_def.convert_index(template_obj,node_vdd[0,0], node_vdd[0,1]))))
    print("x,y %d %d"%(dimx,dimy))
    for i in tqdm(range(g_start[1][0])):
        #print(i)
        J = np.zeros((g_size,1))
        J[i] = -5e-6
        #J[g_start[0][0]:g_start[1][0]] = -5e-6
        J = np.concatenate((J, J_add_vdds), axis=0)
        J = sparse_mat.dok_matrix(J)
        solution = eq_obj.solve_ir(G, J)
        V = solution[i]
        max_drop[i] = settings_obj.VDD - V
        e_time = time.time()
        #print("i = %d R = %f "%(i,max_drop[i]/5e-6))
        #print("time: %d"%(e_time-s_time))
        s_time= e_time
    R = max_drop/5e-6
    R = R.reshape((dimx,dimy), order='F')
    R = R.T
    img.imsave('./output/R_map.png', R)
    with open('./output/R-map.csv', 'wb') as outfile:
        np.savetxt(outfile,R,delimiter=',')

if __name__ == '__main__':
    main()
