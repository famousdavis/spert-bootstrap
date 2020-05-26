# The raw SPERT algorithm for computing
# predictions with simulated errors

# Load the libraries
library(boot)
library(ggplot2)

# Initialize the variables
done <- read.csv('SPERT_rawdata.csv')[,] # How much was done
todo_target_init <- 552 # How much to do
n_steps_ahead <- 10 # How many steps ahead to predict
R_boot <- 10^3 # How many samples to simulate
confidence <- 0.9 # Confidence level of intervals to be computed

# Compute the work already done
todo_done_table <- matrix(NA, length(done), 2)
todo_target <- todo_target_init
for (init_step in seq(length(done)))
  {
    todo_target <- todo_target - done[init_step]
    todo_done_table[init_step, 1] <- todo_target
    todo_done_table[init_step, 2] <- done[init_step]
  }

# Bootstrap the mean distribution
bootmean <- function(data, index)
  {
    data <- data[index]
    return(mean(data))
  }
done_boot <- boot(done, bootmean, R_boot)
done_distr <- done_boot$t

# Simulate the work progress
done_simulated <- matrix(NA, R_boot, n_steps_ahead)
done_simulated_step <- todo_target - done_distr

for (step in seq(n_steps_ahead))
  {
    done_simulated[, step] <- done_simulated_step
    done_simulated_step <- done_simulated_step - done_distr
}

# Create a summary table 
done_simulated_summary <- matrix(NA, n_steps_ahead, 3)

for(step in seq(n_steps_ahead))
  {
    mean_step <- mean(done_simulated[, step])
    lower_step <- as.numeric(quantile(done_simulated[, step], (1 - confidence) / 2))
    upper_step <- as.numeric(quantile(done_simulated[, step], confidence + ((1 - confidence) / 2)))
    done_simulated_summary[step, ] <- c(mean_step, lower_step, upper_step)
  }

done_simulated_summary <- as.data.frame(done_simulated_summary)
colnames(done_simulated_summary) <- c('mean', 'lower_ci', 'upper_ci') # This table shows total work left to do

# Make a plot
# Create a plot table 
plot_summary_table <- done_simulated_summary
plot_todo_done_table <- as.data.frame(cbind(todo_done_table[, 1], todo_done_table[, 1], todo_done_table[, 1]))
colnames(plot_todo_done_table) <- c('mean', 'lower_ci', 'upper_ci')
plot_summary_table <- rbind(plot_todo_done_table, plot_summary_table)
plot_summary_table <- todo_target_init - plot_summary_table #Make a reverse plot
plot_summary_table <- cbind(seq(nrow(plot_summary_table)), plot_summary_table)
colnames(plot_summary_table) <-  c('day', 'mean', 'lower_ci', 'upper_ci') # Add day number

# Create the plot 
p <- ggplot(data = plot_summary_table, aes(x = day, y = mean)) + 
  geom_point() +
  geom_line() + 
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci), linetype=2, alpha=0.1) +
  geom_hline(yintercept = todo_target_init, color = 'red') + 
  ggtitle('Work progress plot') + 
  ylab('Work done and projection') + 
  xlab('Time step')
p
