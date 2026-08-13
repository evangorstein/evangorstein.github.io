data {
  int<lower=1> N;             // Number of observations
  int<lower=1> K;             // Number of ordinal categories
  array[N] int<lower=1, upper=K> y; // Observed ordinals
}

parameters {
  real gamma;       // Latent affinity
  simplex[K] p;     // Ordinal probabilities
}

transformed parameters {
  vector[K-1] q;    // The cumulative probabilities
  ordered[K-1] c; // (Internal) cut points

  // Compute the cumulative probabilities
  q[1] = p[1];
  for (k in 2:(K-1)) {
    q[k] = q[k-1] + p[k];
  }

  // Compute cutpoints
  c = logit(q);
}

model {
  // Prior model
  gamma ~ normal(0, 1);
  p ~ dirichlet(rep_vector(1, K)); 
  
  // Observational model
  y ~ ordered_logistic(rep_vector(gamma, N), c);
}
