
#### You only need to run this part ONCE

# clone the template
git clone https://github.com/rearc-data/adx-product-rearc-data-platform-template.git

# remove extra files / folders
cd temple_folder
rm *.md
rm -rf .git
rm pre-processing/pre-processing-code/source_data.py

cd ..


##### Now run the following commands FOR EACH PRODUCT
# Step 1:
# Go to the cloudformation console, find the stack for the product you want to migrate, copy the parameters section, delete the stack

# Step 2: once the stack is deleted:
git clone https://github.com/rearc-data/fred-privately-owned-housing.git
cd fred-privately-owned-housing

git checkout -b rdp
cp -a ../adx-product-rearc-data-platform-template/. ./

# in run.sh
# Step 3: Using the parameters you have copied from the cloudformation stack, 
# and your AWS profile name, update the variable names in run.sh

# Step 4: in sorce.py
# replace: os.getenv('S3_BUCKET') => os.getenv('ASSET_BUCKET')


# Step 5: make sure variabke names are correct in run.sh, then run it
chmod a+x run.sh
./run.sh