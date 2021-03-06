paths = [genpath('libs'), 'common:'];
addpath(paths);

rng(1)

n_space = 5;
cluster_size = 20;
dim_space = 4;
dim_data = 100;

truth = reshape(repmat(1:n_space,cluster_size,1),1,n_space*cluster_size)';

lambda = 0.1;
lambda2_nn = 4;
lambda2_l1l2 = 0.2;
% 0.1 is good for l1_l2

num_runs = 10;
noise_mag = 0.3;

missrate_collab_shared = zeros(num_runs, 1);
missrate_collab_nn = zeros(num_runs, 1);
missrate_collab_l1l2 = zeros(num_runs, 1);
missrate_lrr_1 = zeros(num_runs, 1);
missrate_lrr_2 = zeros(num_runs, 1);
diff_collab_nn = zeros(num_runs, 1);
diff_collab_l1l2 = zeros(num_runs, 1);
diff_lrr = zeros(num_runs, 1);
psnr_list = zeros(num_runs, 2);

for k = 1 : num_runs

    B1 = gen_subspace_data(dim_data, dim_space, cluster_size, n_space);
    B2 = gen_subspace_data(dim_data, dim_space, cluster_size, n_space);
    
    noise = randn(size(B1));
    w = noise * noise_mag;
    X1 = B1 + w;

    noise = randn(size(B2));
    w = noise * noise_mag;
    X2 = B2 + w;
    
    psnr_list(k, 1) = psnr(B1, X1);
    psnr_list(k, 2) = psnr(B2, X2);

    X_1normed = normalize(X1);
    X_2normed = normalize(X2);

    Xs = {X_1normed, X_2normed};
    
    [Z_collab_nn] = solve_collab_nn(Xs, lambda, lambda2_nn);
    
    collab_Z_nn = sqrt(sum(Z_collab_nn.^2, 3));
    
    [collab_clusters_nn,~,~] = ncutW((abs(collab_Z_nn)+abs(collab_Z_nn')), n_space);
    clusters_collab_nn = condense_clusters(collab_clusters_nn,1);
    missrate_collab_nn(k, 1) = Misclassification(clusters_collab_nn, truth);
    
    [Z_collab_l1l2] = solve_collab_l1l2(Xs, lambda, lambda2_l1l2);
    
    collab_Z_l1l2 = sqrt(sum(Z_collab_l1l2.^2, 3));
    
    [collab_clusters_l1l2,~,~] = ncutW((abs(collab_Z_l1l2)+abs(collab_Z_l1l2')), n_space);
    clusters_collab_l1l2 = condense_clusters(collab_clusters_l1l2,1);
    missrate_collab_l1l2(k, 1) = Misclassification(clusters_collab_l1l2, truth);
    
    [Z_lrr_1] = lrr_exact_fro(X_1normed, lambda);
    
    [lrr_clusters_1,~,~] = ncutW((abs(Z_lrr_1)+abs(Z_lrr_1')), n_space);
    clusters_lrr_1 = condense_clusters(lrr_clusters_1,1);
    missrate_lrr_1(k, 1) = Misclassification(clusters_lrr_1, truth);
    
    [Z_lrr_2] = lrr_exact_fro(X_2normed, lambda);
    
    [lrr_clusters_2,~,~] = ncutW((abs(Z_lrr_2)+abs(Z_lrr_2')), n_space);
    clusters_lrr_2 = condense_clusters(lrr_clusters_2,1);
    missrate_lrr_2(k, 1) = Misclassification(clusters_lrr_2, truth);
    
    diff_collab_nn(k, 1) = norm(Z_collab_nn(:,:,1) - Z_collab_nn(:,:,2), 'fro');
    diff_collab_l1l2(k, 1) = norm(Z_collab_l1l2(:,:,1) - Z_collab_l1l2(:,:,2), 'fro');
    diff_lrr(k, 1) = norm(Z_lrr_1 - Z_lrr_2, 'fro');


end

save(['synthetic_test_noise_' num2str(noise_mag) '.mat' ], 'lambda', 'lambda2_nn', 'lambda2_l1l2', 'missrate_collab_shared', 'missrate_collab_nn', 'missrate_collab_l1l2', 'missrate_lrr_1', 'missrate_lrr_2',...
    'diff_collab_nn', 'diff_collab_l1l2', 'diff_lrr', 'noise_mag', 'psnr_list');

rmpath(paths);