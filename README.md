## Rome storage engine using GCS

### What is Rome
Rome is a tool that allows developers on Apple platforms to use:
- Amazon's S3
- Minio
- Ceph
- other S3 compatible object stores
- or/and a local folder
- your own custom engine

as a shared cache for frameworks built with Carthage.

You can learn more about Rome [here](https://github.com/tmspzz/Rome).

### What is this project for
This is another implementation that utilizes GCS (Google Cloud Storage) to provide upload/download/list objects functionalities used in Rome.

### Usage
- Save your GCP credential in your `~/.gcp/rome.json`.
- Replace the `YOUR_BUCKET_ID` in the script with your real bucket id.
- In your `Romefile`, just declare the script as bellow
```
cache: 
  engine: path/to/the/gcs-engine.sh
```