data {
  int<lower=1> N;             // Number of observations
  array[N] int<lower=0, upper=1> action; 
  array[N] int<lower=0, upper=1> intention;
  array[N] int<lower=0, upper=1> contact;
  int<lower=1> K;             // Number of ordinal categories
  array[N] int<lower=1, upper=K> y; // Observed ordinals
}

parameters {
  // Effects
  real bA; // Effect of action without intention
  real bC; // Effect of contact without intention
  real bI; // Effect of intention without action or contact
  real bIA; // Interaction of intention and action
  real bIC; // Interaction of intention and contact
  simplex[K] p; // Ordinal probabilities for situation with no action, no contact, and no intention
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
  bA ~ normal(0, 1);
  bC ~ normal(0, 1);
  bI ~ normal(0, 1);
  bIA ~ normal(0, 1);
  bIC ~ normal(0, 1);
  p ~ dirichlet(rep_vector(1, K)); 
  
  // Observational model
  vector[N] gamma; // Latent affinities
  for (i in 1:N) {
    gamma[i] = bA*action[i] + bC*contact[i] + intention[i]*(bI + bIA*action[i] + bIC*contact[i]); 
  }
  y ~ ordered_logistic(gamma, c);
}
