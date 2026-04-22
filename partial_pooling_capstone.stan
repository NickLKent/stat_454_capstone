data {
  int<lower=1> N;                         // number of rows
  int<lower=1> J;                         
  array[N] int<lower=1, upper=J> sector;  // sector index for 
  vector[N] y;                            //  sector weekly log returns
  vector[N] x;                            //  S&P 500 weekly log returns
}

parameters {
  real mu_alpha;               // overall intercept mean
  real mu_beta;                // overall slope mean

  real<lower=0> tau_alpha;     // sd of sector intercepts
  real<lower=0> tau_beta;      // sd of sector slopes

  vector[J] alpha_raw;         // standardized sector intercepts
  vector[J] beta_raw;          // standardized sector slopes

  real<lower=0> sigma;         // residual sd
}

transformed parameters {
  vector[J] alpha;
  vector[J] beta;

  alpha = mu_alpha + tau_alpha * alpha_raw;
  beta  = mu_beta  + tau_beta  * beta_raw;
}

model {
  // hyperpriors
  mu_alpha ~ normal(0, 1);
  mu_beta  ~ normal(0, 1);

  tau_alpha ~ normal(0, 1);
  tau_beta  ~ normal(0, 1);
  sigma     ~ normal(0, 1);

  // sector-level priors
  alpha_raw ~ normal(0, 1);
  beta_raw  ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha[sector] + beta[sector] .* x, sigma);
}
