function scaled_data = scale_data(data)

max_data = max(data);
min_data = min(data);

max_data(1,9) = 255; max_data(1,10) = 255; max_data(1,11) = 255;
min_data(1,9) = 0; min_data(1,10) = 0; min_data(1,11) = 0;

max_data(1,5) = max_data(1,4);
min_data(1,4) = min_data(1,5);

max_extend = repmat(max_data,size(data,1),1);
min_extend = repmat(min_data,size(data,1),1);

scaled_data = (data-min_extend)./(max_extend-min_extend);
end