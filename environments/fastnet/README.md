# Bris use environment

Contains all dependencies required for training and inference with Bris models.

It is recommended to build the container in the dx2 project to facilitate running the Bris scripts without changing project.

## Testing the environment

Try a manual install and test run of Bris

```bash
# Make sure the environment is on your PATH
export PATH=$NGMOENVS_BASEDIR/envs/bris/main/bin:$PATH

# Check out the Bris script
git clone https://git.nci.org.au/bom/cm/aifs_scripts.git 

# With resources requested
# IC preparation
envrun ./prepare_ICs.py opendata_aifs.yaml
# Model running
envrun ./run_AIFS.py opendata_aifs.yaml
# Postprocessing
envrun ./postprocess_forecast.py opendata_aifs.yaml
```
