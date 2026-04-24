data {
  int<lower=1> N; // number of sectors
  int<lower=2> T; // number of time points
  matrix[N, T] y; // y[i,t] = cumulative log return for sector i at time t
  vector[T] m; // market proxy at each time t

  // gamma prior parameters for precision = 1/tau = 1/sigma^2
  real<lower=0> a_tau;
  real<lower=0> b_tau;
  
  real alpha_mu;
  real<lower=0> alpha_sd;
  
  real phi_transform_mu;
  real<lower=0> phi_transform_sd;
  
  real beta_transform_mu;
  real<lower=0> beta_transform_sd;
}

parameters {
  vector[N] alpha; // sector intercepts
  vector[N] phi_transform;  // transformation of phi parameters
  vector[N] beta_transform; // transformation of beta parameters
  real<lower=0> tau; // variance
}

transformed parameters {
  vector[N] phi;
  vector[N] beta;
  real<lower=0> precision;

  for (i in 1:N) {
    phi[i] = 2 * inv_logit(phi_transform[i]) - 1;
    beta[i] = 2 * inv_logit(beta_transform[i]) - 1;
  }
  
  precision = 1 / tau;
}

model {
  // priors
  target += normal_lpdf(alpha | alpha_mu, alpha_sd);
  target += normal_lpdf(phi_transform | phi_transform_mu, phi_transform_sd);
  target += normal_lpdf(beta_transform | beta_transform_mu, beta_transform_sd);
  target += gamma_lpdf(precision | a_tau, b_tau);

  // likelihood
  for (i in 1:N) {
    for (t in 2:T) {
      target += normal_lpdf(y[i, t] | alpha[i] + phi[i] * y[i, t-1] + beta[i] * m[t-1], sqrt(tau));
    }
  }
}

