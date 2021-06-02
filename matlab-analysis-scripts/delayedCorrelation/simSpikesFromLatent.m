function [spike_vec, spike_times] = simSpikesFromLatent(latent_spikes_per_s, time_steps)


    spike_vec = poissrnd(latent_spikes_per_s);
    spike_times = time_steps(find(spike_vec >= 1));


end 